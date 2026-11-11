import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:leximpactai/domain/model/case_blueprint.dart';
import 'package:leximpactai/domain/model/generated_case.dart';
import 'package:leximpactai/domain/service/knowledge_base.dart';
import 'package:leximpactai/domain/service/rule_engine.dart';

import 'gemini_service.dart';
import 'rag_service.dart';

class SimulationFeedback {
  final Evaluation evaluation;
  final RagResult references;

  /// Markdown dengan bagian `## Alasan`, `## Dasar Hukum`, `## Saran`
  /// yang dibaca oleh AIFeedbackPage.
  final String markdown;

  /// `true` bila bagian Alasan & Saran ditulis oleh Gemini.
  final bool aiGenerated;

  const SimulationFeedback({
    required this.evaluation,
    required this.references,
    required this.markdown,
    required this.aiGenerated,
  });
}

/// Alur simulasi:
/// 1. Kasus diambil dari bank blueprint lokal (kunci jawaban & pasal acuan
///    sudah pasti), lalu Gemini menulis ulang narasinya agar bervariasi.
/// 2. Jawaban dinilai [RuleEngine] secara deterministik.
/// 3. Pasal dicari dengan [RagService] lokal; Gemini hanya menjelaskan
///    Alasan & Saran, sedangkan Dasar Hukum diambil langsung dari data
///    lokal sehingga pasal tidak bisa dikarang AI.
///
/// Bila Gemini gagal (offline, timeout, output rusak), semua langkah tetap
/// berjalan memakai narasi dan penjelasan bawaan blueprint.
class SimulationAIService {
  final GeminiService _gemini;
  final RuleEngine _ruleEngine;
  final Random _random;

  /// ID kasus yang baru dimainkan, agar tidak cepat terulang.
  static final List<String> _recentCaseIds = [];
  static const int _recentLimit = 12;

  SimulationAIService({
    GeminiService? gemini,
    RuleEngine? ruleEngine,
    Random? random,
  })  : _gemini = gemini ?? GeminiService(),
        _ruleEngine = ruleEngine ?? RuleEngine(),
        _random = random ?? Random();

  /// =========================
  /// 🎲 GENERATE CASE
  /// =========================
  Future<GeneratedCase> generateCase(int level) async {
    final kb = await KnowledgeBase.load();
    final blueprint = _pickBlueprint(kb.casesForLevel(level));
    final rewritten = await _rewriteScenario(blueprint);

    return GeneratedCase(
      blueprint: blueprint,
      scenario: rewritten ?? blueprint.skenario,
      options: _displayOptions(blueprint),
      aiScenario: rewritten != null,
    );
  }

  /// =========================
  /// 🧠 ANALYZE
  /// =========================
  /// Isi [answer] untuk kasus pilihan, atau [steps] untuk kasus susun
  /// langkah.
  Future<SimulationFeedback> analyze(
    GeneratedCase generatedCase, {
    String? answer,
    List<String>? steps,
  }) async {
    final evaluation = generatedCase.isStepCase
        ? _ruleEngine.evaluateSteps(generatedCase, steps ?? const [])
        : _ruleEngine.evaluateChoice(generatedCase, answer ?? '');

    final kb = await KnowledgeBase.load();
    final references = RagService(kb).retrieve(
      query: _ragQuery(generatedCase, evaluation),
      pinnedIds: generatedCase.blueprint.refs,
      tahap: generatedCase.blueprint.tahap,
    );

    var explanation = await _explainWithAI(generatedCase, evaluation, references);
    final aiGenerated = explanation != null;
    explanation ??= _fallbackExplanation(evaluation);

    return SimulationFeedback(
      evaluation: evaluation,
      references: references,
      markdown: _buildMarkdown(
        generatedCase,
        evaluation,
        references,
        alasan: explanation.alasan,
        saran: explanation.saran,
      ),
      aiGenerated: aiGenerated,
    );
  }

  CaseBlueprint _pickBlueprint(List<CaseBlueprint> candidates) {
    if (candidates.isEmpty) {
      throw StateError('Tidak ada kasus untuk level ini di kasus.json');
    }

    final fresh =
        candidates.where((c) => !_recentCaseIds.contains(c.id)).toList();
    final pool = fresh.isEmpty ? candidates : fresh;
    final picked = pool[_random.nextInt(pool.length)];

    _recentCaseIds.add(picked.id);
    if (_recentCaseIds.length > _recentLimit) _recentCaseIds.removeAt(0);
    return picked;
  }

  List<String> _displayOptions(CaseBlueprint blueprint) {
    if (blueprint.isStepCase) {
      final shuffled = List.of(blueprint.langkah);
      // Pastikan susunan awal tidak kebetulan sudah benar.
      do {
        shuffled.shuffle(_random);
      } while (shuffled.length > 1 && listEquals(shuffled, blueprint.langkah));
      return shuffled;
    }

    final options = blueprint.pilihan.map((o) => o.teks).toList();
    // Level 1 memakai pilihan baku Terima/Tolak/Revisi, urutannya tetap.
    if (blueprint.level != 1) options.shuffle(_random);
    return options;
  }

  Future<String?> _rewriteScenario(CaseBlueprint blueprint) async {
    final prompt = """
Anda penulis studi kasus hukum ketenagakerjaan Indonesia untuk mahasiswa.

Tulis ulang skenario di bawah dengan nama perusahaan, nama tokoh, bidang usaha, dan detail latar yang BERBEDA. Semua fakta kunci WAJIB tetap ada dan maknanya tidak boleh berubah.

Judul kasus: ${blueprint.judul}

Skenario asli:
${blueprint.skenario}

Fakta kunci (wajib dipertahankan):
${blueprint.fakta.map((f) => '- $f').join('\n')}

Aturan:
- 2-4 kalimat, bahasa Indonesia baku.
- Jangan menyebut pasal atau undang-undang.
- Jangan memberi petunjuk jawaban dan jangan menilai benar/salah.
- Jangan menambah fakta yang dapat mengubah jawaban yang benar.

Output JSON: {"scenario": "..."}
""";

    try {
      final output =
          await _gemini.generate(prompt, temperature: 0.8, jsonMode: true);
      final json = _decodeJsonObject(output);
      final scenario = (json?['scenario'] as String?)?.trim() ?? '';
      if (scenario.length < 80 || scenario.length > 900) return null;
      return scenario;
    } catch (e) {
      debugPrint('Rewrite scenario gagal, pakai skenario bawaan: $e');
      return null;
    }
  }

  Future<_Explanation?> _explainWithAI(
    GeneratedCase generatedCase,
    Evaluation evaluation,
    RagResult references,
  ) async {
    final prompt = """
Anda dosen hukum ketenagakerjaan Indonesia yang memberi umpan balik kepada mahasiswa.
Penilaian SUDAH DITETAPKAN sistem. Jangan mengubah status, skor, maupun jawaban terbaik.

Kasus:
${generatedCase.scenario}

Pertanyaan:
${generatedCase.question}

${_evaluationSummary(evaluation)}

Referensi hukum (HANYA boleh merujuk daftar ini, sebut dengan nomornya, mis. [1]):
${references.context}

Tugas:
- "alasan": 2-3 kalimat pendek yang menjelaskan mengapa keputusan mahasiswa dinilai demikian, kaitkan dengan referensi.
- "saran": 2-3 poin tindakan HR yang konkret dan sesuai hukum.
- Jangan menyebut pasal atau undang-undang di luar daftar referensi.
- Jangan memberi skor.

Output JSON: {"alasan": ["..."], "saran": ["..."]}
""";

    try {
      final output =
          await _gemini.generate(prompt, temperature: 0.2, jsonMode: true);
      final json = _decodeJsonObject(output);
      if (json == null) return null;

      final alasan = _stringList(json['alasan']);
      final saran = _stringList(json['saran']);
      if (alasan.isEmpty || saran.isEmpty) return null;

      return _Explanation(alasan: alasan, saran: saran);
    } catch (e) {
      debugPrint('Analisis AI gagal, pakai penjelasan lokal: $e');
      return null;
    }
  }

  String _evaluationSummary(Evaluation evaluation) {
    if (evaluation.isStepEvaluation) {
      final misplaced = evaluation.misplacedSteps;
      return """
Status: ${evaluation.statusLabel} (skor ${evaluation.score}/100)

Urutan langkah yang benar:
${_numbered(evaluation.correctSteps)}

Urutan susunan mahasiswa:
${_numbered(evaluation.stepChecks.map((c) => c.step).toList())}

Langkah yang posisinya keliru:
${misplaced.isEmpty ? '(tidak ada)' : misplaced.map((c) => '- "${c.step}" di urutan ${c.userPosition}, seharusnya ${c.correctPosition}').join('\n')}
""";
    }

    return """
Status: ${evaluation.statusLabel} (skor ${evaluation.score}/100)
Jawaban mahasiswa: ${evaluation.userAnswer}
Catatan sistem untuk jawaban mahasiswa: ${evaluation.userExplanation}
Jawaban terbaik: ${evaluation.bestAnswer}
Catatan sistem untuk jawaban terbaik: ${evaluation.bestExplanation}
""";
  }

  _Explanation _fallbackExplanation(Evaluation evaluation) {
    if (evaluation.isStepEvaluation) {
      final misplaced = evaluation.misplacedSteps;
      return _Explanation(
        alasan: misplaced.isEmpty
            ? ['Seluruh langkah sudah tersusun sesuai urutan prosedur yang sah.']
            : [
                'Ada ${misplaced.length} langkah yang posisinya belum tepat.',
                ...misplaced.map(
                  (c) => '"${c.step}" seharusnya berada di urutan '
                      '${c.correctPosition}, bukan ${c.userPosition}.',
                ),
              ],
        saran: [
          'Ikuti urutan prosedur: ${evaluation.correctSteps.join(' → ')}.',
          'Dokumentasikan setiap tahap secara tertulis sebagai bukti kepatuhan.',
        ],
      );
    }

    return _Explanation(
      alasan: [
        if (evaluation.userExplanation.isNotEmpty) evaluation.userExplanation,
        if (!evaluation.isCorrect)
          'Jawaban terbaik adalah "${evaluation.bestAnswer}": '
              '${evaluation.bestExplanation}',
      ],
      saran: [
        if (!evaluation.isCorrect) evaluation.bestExplanation,
        'Dokumentasikan keputusan beserta dasar hukumnya agar dapat dipertanggungjawabkan.',
      ],
    );
  }

  String _buildMarkdown(
    GeneratedCase generatedCase,
    Evaluation evaluation,
    RagResult references, {
    required List<String> alasan,
    required List<String> saran,
  }) {
    final subject = generatedCase.isStepCase ? 'STRATEGI' : 'JAWABAN';
    final icon = switch (evaluation.status) {
      EvaluationStatus.benar => '✅',
      EvaluationStatus.kurangTepat => '⚠️',
      EvaluationStatus.salah => '❌',
    };

    final dasarHukum = references.hits.map((hit) {
      final doc = hit.document;
      final catatan = doc.catatan == null ? '' : ' (Catatan: ${doc.catatan})';
      return '- ${doc.citation} — ${doc.judul}: ${doc.excerpt(600)}$catatan';
    });

    return [
      '$icon $subject ${evaluation.statusLabel} · Skor ${evaluation.score}/100',
      '',
      '## Alasan',
      ...alasan.map((line) => '- $line'),
      '',
      '## Dasar Hukum',
      ...dasarHukum,
      '',
      '## Saran',
      ...saran.map((line) => '- $line'),
    ].join('\n');
  }

  String _ragQuery(GeneratedCase generatedCase, Evaluation evaluation) {
    return [
      generatedCase.scenario,
      generatedCase.blueprint.topik.join(' '),
      evaluation.bestAnswer,
      evaluation.correctSteps.join(' '),
    ].where((part) => part.trim().isNotEmpty).join('\n');
  }

  Map<String, dynamic>? _decodeJsonObject(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start == -1 || end <= start) return null;
    try {
      final decoded = jsonDecode(text.substring(start, end + 1));
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  List<String> _stringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (value is String && value.trim().isNotEmpty) return [value.trim()];
    return const [];
  }

  String _numbered(List<String> items) => [
        for (var i = 0; i < items.length; i++) '${i + 1}. ${items[i]}',
      ].join('\n');
}

class _Explanation {
  final List<String> alasan;
  final List<String> saran;

  const _Explanation({required this.alasan, required this.saran});
}
