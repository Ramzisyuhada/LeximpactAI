import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:leximpactai/domain/model/generated_case.dart';
import 'package:leximpactai/domain/service/knowledge_base.dart';
import 'package:leximpactai/domain/service/gemini_service.dart';
import 'package:leximpactai/domain/service/rag_service.dart';
import 'package:leximpactai/domain/service/rule_engine.dart';
import 'package:leximpactai/domain/service/simulation_ai_service.dart';

class _OfflineGemini extends GeminiService {
  @override
  Future<String> generate(
    String prompt, {
    double temperature = 0.7,
    bool jsonMode = false,
  }) async {
    throw GeminiException('offline');
  }
}

class _FakeGemini extends GeminiService {
  @override
  Future<String> generate(
    String prompt, {
    double temperature = 0.7,
    bool jsonMode = false,
  }) async {
    if (prompt.contains('Tulis ulang skenario')) {
      return '{"scenario": "CV Harapan Baru membuka lowongan kasir dengan syarat usia maksimal 28 tahun. Pelamar berusia 47 tahun meraih nilai tes tertinggi, namun kepala toko meminta HR menolaknya karena usianya."}';
    }
    return '{"alasan": ["Syarat usia tidak relevan dengan jabatan [1]."], "saran": ["Hapus syarat usia.", "Nilai berdasarkan kompetensi."]}';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final kb = KnowledgeBase.fromJsonStrings(
    regulationsJson: File('assets/data/regulasi.json').readAsStringSync(),
    casesJson: File('assets/data/kasus.json').readAsStringSync(),
  );

  group('Data lokal', () {
    test('setiap level punya kasus', () {
      for (final level in [1, 2, 3]) {
        expect(kb.casesForLevel(level), isNotEmpty, reason: 'level $level');
      }
    });

    test('semua referensi pasal di kasus ada di regulasi', () {
      for (final c in kb.cases) {
        for (final ref in c.refs) {
          expect(kb.documentById(ref), isNotNull, reason: '${c.id} → $ref');
        }
      }
    });

    test('kasus pilihan punya tepat satu jawaban skor 100', () {
      for (final c in kb.cases.where((c) => !c.isStepCase)) {
        final perfect = c.pilihan.where((o) => o.skor == 100);
        expect(perfect.length, 1, reason: c.id);
      }
    });

    test('kasus Level 3 berupa susun langkah', () {
      for (final c in kb.casesForLevel(3)) {
        expect(c.langkah.length, greaterThanOrEqualTo(3), reason: c.id);
      }
    });
  });

  group('RAG lokal', () {
    final rag = RagService(kb);

    List<String> top(String query, [int k = 3]) =>
        rag.search(query, topK: k).map((h) => h.document.id).toList();

    test('menemukan pasal asli yang tepat untuk berbagai istilah', () {
      expect(top('karyawan disuruh lembur tanpa dibayar'),
          contains('uu13-2003-p78'));
      expect(top('alih daya untuk lini produksi'), contains('uu13-2003-p66'));
      expect(top('pekerja tidak masuk kerja 7 hari tanpa kabar'),
          contains('uu13-2003-p168'));
      expect(top('cuti melahirkan'), contains('uu13-2003-p82'));
      expect(top('pemutusan hubungan kerja karena efisiensi'),
          contains('uu13-2003-p164'));
      expect(top('perundingan bipartit gagal'), contains('uu2-2004-p3'));
    });

    test('pasal acuan kasus ikut muncul di hasil pencarian skenarionya', () {
      // Ukuran kualitas RAG: untuk berapa kasus, minimal satu pasal acuan
      // blueprint masuk 5 besar pencarian dari narasi kasusnya.
      var casesWithRef = 0;
      for (final c in kb.cases) {
        final best = c.isStepCase ? c.langkah.join(' ') : c.bestOption.teks;
        final ids = rag
            .search('${c.skenario}\n${c.topik.join(' ')}\n$best',
                tahap: c.tahap, topK: 5)
            .map((h) => h.document.id);
        if (c.refs.any(ids.contains)) casesWithRef++;
      }
      expect(casesWithRef, greaterThanOrEqualTo(16));
    });

    test('teks pasal berasal dari PDF asli', () {
      final p78 = kb.documentById('uu13-2003-p78')!;
      expect(p78.isi, contains('wajib membayar upah kerja lembur'));
      expect(p78.penjelasan, isNotNull);
      expect(kb.documentById('uu13-2003-p164')!.catatan, contains('dihapus'));
    });

    test('referensi blueprint selalu ikut dan tidak dobel', () {
      final result = rag.retrieve(
        query: 'lembur tanpa upah lembur',
        pinnedIds: ['uu13-2003-p78', 'uu13-2003-p77'],
      );
      final ids = result.hits.map((h) => h.document.id).toList();
      expect(ids.take(2), ['uu13-2003-p78', 'uu13-2003-p77']);
      expect(ids.toSet().length, ids.length);
    });

    test('query tidak relevan tidak menghasilkan referensi tambahan', () {
      final result = rag.retrieve(query: 'resep nasi goreng enak');
      expect(result.hits, isEmpty);
    });
  });

  group('Penilaian', () {
    final engine = RuleEngine();

    GeneratedCase caseFor(String id) {
      final blueprint = kb.cases.firstWhere((c) => c.id == id);
      return GeneratedCase(
        blueprint: blueprint,
        scenario: blueprint.skenario,
        options: blueprint.isStepCase
            ? blueprint.langkah
            : blueprint.pilihan.map((o) => o.teks).toList(),
      );
    }

    test('jawaban terbaik = BENAR 100', () {
      final result = engine.evaluateChoice(caseFor('L1-usia'), 'Revisi prosedur');
      expect(result.score, 100);
      expect(result.status, EvaluationStatus.benar);
    });

    test('jawaban parsial = KURANG TEPAT', () {
      final result = engine.evaluateChoice(caseFor('L1-usia'), 'Terima');
      expect(result.status, EvaluationStatus.kurangTepat);
      expect(result.bestAnswer, 'Revisi prosedur');
    });

    test('jawaban salah = SALAH 0', () {
      final result = engine.evaluateChoice(caseFor('L1-usia'), 'Tolak');
      expect(result.score, 0);
      expect(result.status, EvaluationStatus.salah);
    });

    test('susunan langkah benar = 100', () {
      final c = caseFor('L3-efisiensi');
      final result = engine.evaluateSteps(c, c.blueprint.langkah);
      expect(result.score, 100);
      expect(result.misplacedSteps, isEmpty);
    });

    test('susunan terbalik = 0, satu tukar posisi tetap dapat nilai parsial',
        () {
      final c = caseFor('L3-efisiensi');
      final steps = c.blueprint.langkah;

      expect(engine.evaluateSteps(c, steps.reversed.toList()).score,
          lessThan(RuleEngine.partialThreshold));

      final swapped = List.of(steps);
      final tmp = swapped[3];
      swapped[3] = swapped[4];
      swapped[4] = tmp;
      final result = engine.evaluateSteps(c, swapped);
      expect(result.status, EvaluationStatus.kurangTepat);
      expect(result.misplacedSteps.length, 2);
    });
  });

  group('SimulationAIService', () {
    test('tetap jalan memakai data lokal saat Gemini gagal', () async {
      final service =
          SimulationAIService(gemini: _OfflineGemini(), random: Random(1));
      final c = await service.generateCase(1);
      expect(c.aiScenario, isFalse);
      expect(c.scenario, c.blueprint.skenario);

      final feedback =
          await service.analyze(c, answer: c.blueprint.bestOption.teks);
      expect(feedback.aiGenerated, isFalse);
      expect(feedback.evaluation.score, 100);
      expect(feedback.markdown, startsWith('✅'));
      expect(feedback.markdown, contains('## Dasar Hukum'));
      expect(feedback.references.hits.first.document.id, c.blueprint.refs.first);
    });

    test('memakai narasi dan penjelasan dari Gemini bila tersedia', () async {
      final service = SimulationAIService(gemini: _FakeGemini());
      final c = await service.generateCase(1);
      expect(c.aiScenario, isTrue);

      final feedback = await service.analyze(c, answer: 'Tolak');
      expect(feedback.aiGenerated, isTrue);
      expect(feedback.markdown, contains('Hapus syarat usia.'));
    });

    test('Level 3 langkah ditampilkan teracak', () async {
      final service =
          SimulationAIService(gemini: _OfflineGemini(), random: Random(7));
      final c = await service.generateCase(3);
      expect(c.options, isNot(equals(c.blueprint.langkah)));
      expect(c.options.toSet(), c.blueprint.langkah.toSet());
    });
  });
}
