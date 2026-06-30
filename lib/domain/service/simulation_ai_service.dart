import 'dart:convert';

import 'package:leximpactai/domain/model/generated_case.dart';
import 'package:leximpactai/domain/service/rule_engine.dart';
import 'package:leximpactai/domain/utils/generated_case_parser.dart';

import 'mistral_service.dart';
import 'rag_service.dart';

class SimulationAIService {
  final mistral = MistralService();
  final rag = RagService();
  final ruleEngine = RuleEngine();

  static const int _maxJsonRetryAttempts = 2;
  static final Map<String, GeneratedCase> _caseRegistry = {};
  static GeneratedCase? _lastGeneratedCase;

  /// =========================
  /// 🔥 ANALYZE LEVEL 1 & 2
  /// =========================
  Future<String> analyze({
    required String scenario,
    required String userAnswer,
  }) async {
    final generatedCase = _lookupCase(scenario) ??
      _fallbackCaseForAnalysis(scenario: scenario);
    final stableCase = ruleEngine.applyRules(generatedCase);
    final evaluation = ruleEngine.evaluateAnswer(
      generatedCase: stableCase,
      userAnswer: userAnswer,
    );

    final ragResult = await rag.getContextChecked(
      _buildRagQuery(
        scenario: scenario,
        userAnswer: userAnswer,
        correctAnswer: evaluation.correctAnswer,
        lawTopics: stableCase.lawTopics,
      ),
    );
    final contextBlock = _contextBlock(ragResult);

    final basePrompt = """
Anda adalah ahli hukum ketenagakerjaan Indonesia.

BATASAN WAJIB:
- Keputusan terbaik SUDAH ditentukan sistem.
- Status benar/salah SUDAH ditentukan sistem.
- Jangan menentukan jawaban terbaik.
- Jangan menentukan benar atau salah.
- Jangan memberi skor.
- Jangan menyarankan langkah sebagai hasil evaluasi benar/salah.

Kasus:
$scenario

Keputusan terbaik SUDAH ditentukan sistem.
Status jawaban user:
${evaluation.status}

Jawaban terbaik:
${evaluation.correctAnswer}

Jawaban user:
${evaluation.userAnswer}

Topik hukum:
${_formatList(stableCase.lawTopics)}

Referensi hukum:
$contextBlock

Tugas AI:
- Jelaskan alasan hukum
- Jelaskan pasal atau dasar hukum yang relevan dari referensi
- Jelaskan risiko
- Jelaskan dampak
- Berikan rekomendasi

Output HARUS JSON valid tanpa markdown dan tanpa teks tambahan:
{
  "reason": "",
  "risk": [],
  "impact": [],
  "recommendation": []
}
""";

    return _generateJsonWithRetry(
      basePrompt: basePrompt,
      fallbackJson: _fallbackAnswerJson(evaluation),
    );
  }

  /// =========================
  /// 🔥 LEVEL 1 (FIXED)
  /// =========================
  Future<String> generateCase() async {
    final prompt = """
Buat 1 kasus HR tentang diskriminasi usia.

Jangan menentukan jawaban benar, jangan memberi evaluasi, dan jangan memberi skor.

Output HARUS JSON valid tanpa markdown:
{
  "scenario": "Tulisan 2-3 kalimat",
  "options": ["Terima", "Tolak", "Revisi prosedur"],
  "lawTopics": ["diskriminasi usia", "rekrutmen non-diskriminatif"]
}

ATURAN:
- Jangan ubah kata pilihan.
- Gunakan bahasa Indonesia.
""";

    final generatedCase = await _generateCaseFromAI(
      prompt: prompt,
      fallbackOptions: RuleEngine.level1Options,
      fallbackLawTopics: RuleEngine.level1LawTopics,
    );
    final stableCase = ruleEngine.applyRules(
      generatedCase.copyWith(
        options: RuleEngine.level1Options,
        lawTopics: RuleEngine.level1LawTopics,
      ),
    );
    _rememberCase(stableCase);

    return stableCase.toJsonString();
  }

  /// =========================
  /// 🔥 LEVEL 2 (DINAMIS)
  /// =========================
  Future<String> generateCaseLevel2() async {
    final prompt = """
Buat 1 kasus HR kompleks tentang konflik lembur, upah, dan keselamatan kerja.

Jangan menentukan jawaban benar, jangan memberi evaluasi, dan jangan memberi skor.

Output HARUS JSON valid tanpa markdown:
{
  "scenario": "Tulisan 2-3 kalimat",
  "options": ["opsi singkat", "opsi singkat", "opsi singkat"],
  "lawTopics": ["lembur", "upah", "keselamatan kerja"]
}

ATURAN:
- Setiap pilihan maksimal 15 kata.
- Buat 3 pilihan tindakan HR yang realistis.
- Jangan gunakan A/B/C.
- Jangan ada penjelasan tambahan.
""";

    final generatedCase = await _generateCaseFromAI(
      prompt: prompt,
      fallbackOptions: const [
        'Bayar lembur dan audit jadwal kerja',
        'Abaikan keluhan karena target produksi',
        'Mediasi dan perbaiki prosedur keselamatan',
      ],
      fallbackLawTopics: RuleEngine.level2LawTopics,
    );
    final stableCase = ruleEngine.applyRules(
      generatedCase.copyWith(
        options: _normalizeOptions(
          generatedCase.options,
          const [
            'Bayar lembur dan audit jadwal kerja',
            'Abaikan keluhan karena target produksi',
            'Mediasi dan perbaiki prosedur keselamatan',
          ],
          maxItems: 3,
        ),
        lawTopics: generatedCase.lawTopics.isEmpty
            ? RuleEngine.level2LawTopics
            : generatedCase.lawTopics,
      ),
    );
    _rememberCase(stableCase);

    return stableCase.toJsonString();
  }

  /// =========================
  /// 🔥 LEVEL 3 (LANGKAH GAME)
  /// =========================
  Future<String> generateCaseLevel3() async {
    final prompt = """
Buat satu kasus HR kompleks tentang PHK karena efisiensi perusahaan.

Jangan membuat daftar langkah benar.
Jangan menentukan strategi terbaik.
Jangan memberi evaluasi.

Output HARUS JSON valid tanpa markdown:
{
  "scenario": "Tulisan 2-3 kalimat",
  "lawTopics": ["PHK efisiensi", "perundingan bipartit", "pesangon"]
}

ATURAN:
- Gunakan bahasa Indonesia.
- Jangan ada penjelasan tambahan.
""";

    final generatedCase = await _generateCaseFromAI(
      prompt: prompt,
      fallbackOptions: RuleEngine.level3CorrectSteps,
      fallbackLawTopics: RuleEngine.level3LawTopics,
      stepCase: true,
    );
    final stableCase = ruleEngine.applyRules(
      generatedCase.copyWith(
        options: RuleEngine.level3CorrectSteps,
        lawTopics: generatedCase.lawTopics.isEmpty
            ? RuleEngine.level3LawTopics
            : generatedCase.lawTopics,
      ),
      stepCase: true,
    );
    _rememberCase(stableCase);

    return stableCase.toJsonString();
  }

  /// =========================
  /// 🔥 ANALYZE LEVEL 3
  /// =========================
  Future<String> analyzeLevel3({
    required String scenario,
    required String userAnswer,
  }) async {
    final generatedCase = ruleEngine.applyRules(
      _lookupCase(scenario) ??
          GeneratedCase(
            scenario: scenario,
            options: RuleEngine.level3CorrectSteps,
            correctAnswer: RuleEngine.level3CorrectSteps.join(' -> '),
            lawTopics: RuleEngine.level3LawTopics,
          ),
      stepCase: true,
    );
    final userSteps = _splitUserSteps(userAnswer);
    final evaluation = ruleEngine.evaluateSteps(
      generatedCase: generatedCase,
      userSteps: userSteps,
    );

    final ragResult = await rag.getContextChecked(
      _buildRagQuery(
        scenario: scenario,
        userAnswer: userAnswer,
        correctAnswer: generatedCase.correctAnswer,
        lawTopics: generatedCase.lawTopics,
      ),
    );
    final contextBlock = _contextBlock(ragResult);

    final basePrompt = """
Anda adalah ahli hukum ketenagakerjaan Indonesia.

BATASAN WAJIB:
- Urutan langkah benar SUDAH ditentukan sistem.
- Status strategi user SUDAH ditentukan sistem.
- Jangan menentukan langkah terbaik.
- Jangan menentukan benar atau salah.
- Jangan memberi skor.

Kasus:
$scenario

Status strategi user:
${evaluation.status}

Langkah benar menurut sistem:
${_formatNumberedList(evaluation.correctSteps)}

Langkah user:
${_formatNumberedList(evaluation.userSteps)}

Langkah yang salah:
${_formatList(evaluation.wrongSteps)}

Langkah yang urutannya keliru:
${_formatList(evaluation.misorderedSteps)}

Langkah yang dilewati:
${_formatList(evaluation.missedSteps)}

Referensi hukum:
$contextBlock

Tugas AI:
- Jelaskan langkah yang salah
- Jelaskan langkah yang dilewati
- Jelaskan konsekuensi hukum
- Jelaskan risiko dan dampak
- Berikan rekomendasi perbaikan

Output HARUS JSON valid tanpa markdown dan tanpa teks tambahan:
{
  "reason": "",
  "risk": [],
  "impact": [],
  "recommendation": []
}
""";

    return _generateJsonWithRetry(
      basePrompt: basePrompt,
      fallbackJson: _fallbackStepJson(evaluation),
    );
  }

  /// Converts AI case output into a structured model.
  Future<GeneratedCase> _generateCaseFromAI({
    required String prompt,
    required List<String> fallbackOptions,
    required List<String> fallbackLawTopics,
    bool stepCase = false,
  }) async {
    final rawOutput = await mistral.generate(prompt, temperature: 0.4);

    return GeneratedCaseParser.parse(
      rawOutput,
      fallbackOptions: fallbackOptions,
      fallbackLawTopics: fallbackLawTopics,
      stepCase: stepCase,
    );
  }

  Future<String> _generateJsonWithRetry({
    required String basePrompt,
    required Map<String, dynamic> fallbackJson,
  }) async {
    var prompt = basePrompt;

    for (var attempt = 0; attempt <= _maxJsonRetryAttempts; attempt++) {
      final output = await mistral.generate(prompt, temperature: 0.2);
      final parsed = _parseAnalysisJson(output);

      if (parsed != null) {
        return const JsonEncoder.withIndent('  ').convert(parsed);
      }

      if (attempt == _maxJsonRetryAttempts) break;

      prompt = """
$basePrompt

PERBAIKAN DIPERLUKAN:
Output sebelumnya bukan JSON valid sesuai schema.
Tulis ulang hanya sebagai JSON valid tanpa markdown, tanpa code fence, dan tanpa teks tambahan.
""";
    }

    return const JsonEncoder.withIndent('  ').convert(fallbackJson);
  }

  Map<String, dynamic>? _parseAnalysisJson(String output) {
    final jsonText = _extractJsonObject(output);
    if (jsonText == null) return null;

    try {
      final decoded = jsonDecode(jsonText);
      if (decoded is! Map) return null;
      final json = Map<String, dynamic>.from(decoded);
      final result = {
        'reason': _jsonString(json, const ['reason', 'alasan']),
        'risk': _jsonStringList(json, const ['risk', 'risiko']),
        'impact': _jsonStringList(json, const ['impact', 'dampak']),
        'recommendation': _jsonStringList(
          json,
          const ['recommendation', 'recommendations', 'rekomendasi'],
        ),
      };

      final hasContent = (result['reason'] as String).isNotEmpty ||
          (result['risk'] as List<String>).isNotEmpty ||
          (result['impact'] as List<String>).isNotEmpty ||
          (result['recommendation'] as List<String>).isNotEmpty;

      return hasContent ? result : null;
    } catch (_) {
      return null;
    }
  }

  String? _extractJsonObject(String output) {
    final clean = output
        .replaceAll(RegExp(r'```json', caseSensitive: false), '')
        .replaceAll('```', '')
        .trim();
    final start = clean.indexOf('{');
    final end = clean.lastIndexOf('}');

    if (start == -1 || end == -1 || end <= start) return null;
    return clean.substring(start, end + 1);
  }

  Map<String, dynamic> _fallbackAnswerJson(AnswerEvaluation evaluation) {
    return {
      'reason':
          'Rule engine menetapkan status ${evaluation.status}. Jawaban terbaik sistem adalah "${evaluation.correctAnswer}", sedangkan jawaban user adalah "${evaluation.userAnswer}".',
      'risk': evaluation.isCorrect
          ? [
              'Risiko hukum lebih rendah karena jawaban mengikuti keputusan terbaik yang ditetapkan sistem.',
            ]
          : [
              'Risiko sengketa ketenagakerjaan meningkat karena jawaban user berbeda dari keputusan terbaik sistem.',
            ],
      'impact': evaluation.isCorrect
          ? [
              'Keputusan lebih konsisten dengan prosedur HR dan perlindungan hak pekerja.',
            ]
          : [
              'Keputusan dapat berdampak pada kepatuhan perusahaan dan posisi pekerja yang terdampak.',
            ],
      'recommendation': [
        'Gunakan keputusan terbaik yang sudah ditetapkan sistem sebagai dasar tindakan.',
        'Pastikan tindakan HR didukung dokumen, prosedur tertulis, dan rujukan hukum yang relevan.',
      ],
    };
  }

  Map<String, dynamic> _fallbackStepJson(StepEvaluation evaluation) {
    final problematicSteps = [
      ...evaluation.wrongSteps,
      ...evaluation.misorderedSteps,
    ];

    return {
      'reason': evaluation.isCorrect
          ? 'Rule engine menetapkan urutan strategi user BENAR karena seluruh langkah sesuai urutan sistem.'
          : 'Rule engine menetapkan urutan strategi user SALAH karena ada langkah yang salah, keliru urutan, atau dilewati.',
      'risk': problematicSteps.isEmpty
          ? [
              'Risiko utama berasal dari langkah yang dilewati atau dokumentasi PHK yang tidak lengkap.',
            ]
          : [
              'Langkah bermasalah: ${problematicSteps.join(', ')}.',
            ],
      'impact': evaluation.missedSteps.isEmpty
          ? [
              'Urutan yang tepat membantu menjaga kepatuhan prosedur PHK.',
            ]
          : [
              'Langkah yang dilewati: ${evaluation.missedSteps.join(', ')}.',
            ],
      'recommendation': [
        'Ikuti urutan langkah benar yang disimpan sistem.',
        'Pastikan perundingan, pemberitahuan, dan pembayaran hak pekerja terdokumentasi.',
      ],
    };
  }

  GeneratedCase? _lookupCase(String scenario) {
    final key = _normalizeKey(scenario);
    return _caseRegistry[key] ??
        (_normalizeKey(_lastGeneratedCase?.scenario ?? '') == key
            ? _lastGeneratedCase
            : null);
  }

  void _rememberCase(GeneratedCase generatedCase) {
    final key = _normalizeKey(generatedCase.scenario);
    if (key.isNotEmpty) {
      _caseRegistry[key] = generatedCase;
    }
    _lastGeneratedCase = generatedCase;
  }

  GeneratedCase _fallbackCaseForAnalysis({
    required String scenario,
  }) {
    final lawTopics = _guessLawTopics(scenario);
    final fallbackOptions = _fallbackOptionsForTopics(lawTopics);

    return ruleEngine.applyRules(
      GeneratedCase(
        scenario: scenario,
        options: _normalizeOptions(fallbackOptions, fallbackOptions),
        correctAnswer: '',
        lawTopics: lawTopics,
      ),
    );
  }

  List<String> _fallbackOptionsForTopics(List<String> lawTopics) {
    final normalizedTopics = lawTopics.map(_normalizeKey).toList();

    if (normalizedTopics.any(
      (topic) => topic.contains('phk') || topic.contains('efisiensi'),
    )) {
      return RuleEngine.level3CorrectSteps;
    }

    if (normalizedTopics.any(
      (topic) =>
          topic.contains('lembur') ||
          topic.contains('upah') ||
          topic.contains('keselamatan'),
    )) {
      return const [
        'Bayar lembur dan audit jadwal kerja',
        'Abaikan keluhan karena target produksi',
        'Mediasi dan perbaiki prosedur keselamatan',
      ];
    }

    return RuleEngine.level1Options;
  }

  List<String> _guessLawTopics(String scenario) {
    final normalized = scenario.toLowerCase();
    if (normalized.contains('phk') || normalized.contains('efisiensi')) {
      return RuleEngine.level3LawTopics;
    }
    if (normalized.contains('lembur') ||
        normalized.contains('upah') ||
        normalized.contains('keselamatan')) {
      return RuleEngine.level2LawTopics;
    }
    return RuleEngine.level1LawTopics;
  }

  List<String> _normalizeOptions(
    List<String> options,
    List<String> fallback, {
    int maxItems = 5,
  }) {
    final values = options
        .map((option) => option.trim())
        .where((option) => option.isNotEmpty)
        .toList();
    final source = values.isEmpty ? fallback : values;
    final deduped = _dedupeStrings(source);

    if (deduped.length > maxItems) {
      return deduped.take(maxItems).toList();
    }
    return deduped;
  }

  List<String> _splitUserSteps(String userAnswer) {
    final arrow = String.fromCharCode(0x2192);
    final normalized = userAnswer
        .replaceAll(arrow, '|')
        .replaceAll('->', '|')
        .replaceAll('\n', '|');

    return normalized
        .split('|')
        .map((step) => step.trim())
        .where((step) => step.isNotEmpty)
        .toList();
  }

  String _buildRagQuery({
    required String scenario,
    required String userAnswer,
    required String correctAnswer,
    required List<String> lawTopics,
  }) {
    return [
      scenario,
      userAnswer,
      correctAnswer,
      lawTopics.join(', '),
    ].where((part) => part.trim().isNotEmpty).join('\n');
  }

  String _contextBlock(RagResult result) {
    return result.isRelevant
        ? result.context
        : '(Tidak ada referensi tambahan yang cukup relevan.)';
  }

  String _formatList(List<String> items) {
    if (items.isEmpty) return '(Tidak ada)';
    return items.map((item) => '- $item').join('\n');
  }

  String _formatNumberedList(List<String> items) {
    if (items.isEmpty) return '(Tidak ada)';
    return [
      for (var i = 0; i < items.length; i++) '${i + 1}. ${items[i]}',
    ].join('\n');
  }

  List<String> _dedupeStrings(List<String> values) {
    final seen = <String>{};
    final result = <String>[];

    for (final value in values) {
      final key = _normalizeKey(value);
      if (seen.add(key)) result.add(value);
    }

    return result;
  }

  String _jsonString(Map<String, dynamic> json, List<String> keys) {
    final value = _jsonValue(json, keys);
    if (value == null) return '';
    if (value is List) {
      return value.map((item) => item.toString()).join(' ').trim();
    }
    return value.toString().trim();
  }

  List<String> _jsonStringList(Map<String, dynamic> json, List<String> keys) {
    final value = _jsonValue(json, keys);
    if (value == null) return const [];

    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return value
        .toString()
        .split(RegExp(r'[;\n]'))
        .map((item) => item.replaceFirst(RegExp(r'^[-*\d.)\s]+'), '').trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  dynamic _jsonValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key)) return json[key];
    }

    final lowered = {
      for (final entry in json.entries) entry.key.toLowerCase(): entry.value,
    };

    for (final key in keys) {
      final value = lowered[key.toLowerCase()];
      if (value != null) return value;
    }

    return null;
  }

  String _normalizeKey(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
