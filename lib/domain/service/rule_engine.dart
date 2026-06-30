import 'package:leximpactai/domain/model/generated_case.dart';

class AnswerEvaluation {
  final bool isCorrect;
  final String status;
  final String correctAnswer;
  final String userAnswer;
  final int score;

  const AnswerEvaluation({
    required this.isCorrect,
    required this.status,
    required this.correctAnswer,
    required this.userAnswer,
    required this.score,
  });
}

class StepEvaluation {
  final bool isCorrect;
  final String status;
  final List<String> correctSteps;
  final List<String> userSteps;
  final List<String> wrongSteps;
  final List<String> missedSteps;
  final List<String> misorderedSteps;

  const StepEvaluation({
    required this.isCorrect,
    required this.status,
    required this.correctSteps,
    required this.userSteps,
    required this.wrongSteps,
    required this.missedSteps,
    required this.misorderedSteps,
  });
}

class RuleEngine {
  static const List<String> level1Options = [
    'Terima',
    'Tolak',
    'Revisi prosedur',
  ];

  static const List<String> level1LawTopics = [
    'diskriminasi usia',
    'rekrutmen non-diskriminatif',
    'kesetaraan kesempatan kerja',
  ];

  static const List<String> level2LawTopics = [
    'lembur',
    'upah',
    'keselamatan kerja',
    'perselisihan hubungan industrial',
  ];

  static const List<String> level3LawTopics = [
    'PHK efisiensi',
    'perundingan bipartit',
    'pesangon',
    'prosedur PHK',
  ];

  static const List<String> level3CorrectSteps = [
    'Audit alasan efisiensi dan bukti kondisi perusahaan',
    'Lakukan perundingan bipartit dengan pekerja atau serikat pekerja',
    'Hitung dan bayarkan seluruh hak pekerja sesuai ketentuan',
  ];

  AnswerEvaluation evaluateAnswer({
    required GeneratedCase generatedCase,
    required String userAnswer,
  }) {
    final correctAnswer = compareChoices(
      generatedCase.options,
      scenario: generatedCase.scenario,
      lawTopics: generatedCase.lawTopics,
    );

    final resolvedCorrectAnswer = correctAnswer.trim().isNotEmpty
        ? correctAnswer.trim()
        : generatedCase.correctAnswer.trim();

    final isCorrect =
        _normalize(userAnswer) == _normalize(resolvedCorrectAnswer);

    return AnswerEvaluation(
      isCorrect: isCorrect,
      status: isCorrect ? 'BENAR' : 'SALAH',
      correctAnswer: resolvedCorrectAnswer,
      userAnswer: userAnswer,
      score: isCorrect ? 100 : 0,
    );
  }

  StepEvaluation evaluateSteps({
    required GeneratedCase generatedCase,
    required List<String> userSteps,
  }) {
    final correctSteps = generatedCase.options.isNotEmpty
        ? generatedCase.options
        : level3CorrectSteps;
    final normalizedCorrect = correctSteps.map(_normalize).toList();
    final normalizedUser = userSteps.map(_normalize).toList();

    final isCorrect = normalizedUser.length == normalizedCorrect.length &&
        _sameOrder(normalizedUser, normalizedCorrect);

    final wrongSteps = <String>[];
    final missedSteps = <String>[];
    final misorderedSteps = <String>[];

    for (var i = 0; i < userSteps.length; i++) {
      final userStep = userSteps[i];
      final normalized = normalizedUser[i];
      final expectedAtIndex =
          i < normalizedCorrect.length ? normalizedCorrect[i] : '';

      if (!normalizedCorrect.contains(normalized)) {
        wrongSteps.add(userStep);
      } else if (normalized != expectedAtIndex) {
        misorderedSteps.add(userStep);
      }
    }

    for (var i = 0; i < correctSteps.length; i++) {
      if (!normalizedUser.contains(normalizedCorrect[i])) {
        missedSteps.add(correctSteps[i]);
      }
    }

    return StepEvaluation(
      isCorrect: isCorrect,
      status: isCorrect ? 'BENAR' : 'SALAH',
      correctSteps: correctSteps,
      userSteps: userSteps,
      wrongSteps: wrongSteps,
      missedSteps: missedSteps,
      misorderedSteps: misorderedSteps,
    );
  }

  String compareChoices(
  List<String> choices, {
  String scenario = '',
  List<String> lawTopics = const [],
}) {
  if (choices.isEmpty) return '';

  final context = _normalize('$scenario ${lawTopics.join(" ")}');

  // =========================
  // RULE 1 : TERIMA
  // =========================
  if (_containsAny(context, [
    'memenuhi syarat',
    'memenuhi kriteria',
    'lulus seleksi',
    'kompetensi sesuai',
    'tidak ada pelanggaran',
    'sesuai prosedur',
    'layak diterima'
  ])) {
    return _findChoice(choices, 'terima');
  }

  // =========================
  // RULE 2 : TOLAK
  // =========================
  if (_containsAny(context, [
    'melanggar',
    'tidak sesuai',
    'bertentangan',
    'dokumen palsu',
    'pemalsuan',
    'fraud',
    'tidak memenuhi syarat',
  ])) {
    return _findChoice(choices, 'tolak');
  }

  // =========================
  // RULE 3 : REVISI
  // =========================
  if (_containsAny(context, [
    'diskriminasi',
    'usia',
    'gender',
    'ras',
    'agama',
    'prosedur rekrutmen',
    'proses rekrutmen',
    'kebijakan hr',
    'perbaikan prosedur'
  ])) {
    return _findChoice(choices, 'revisi');
  }

  // =========================
  // Fallback
  // =========================
  return choices.first;
}

  GeneratedCase applyRules(GeneratedCase generatedCase, {bool stepCase = false}) {
    final options = stepCase ? level3CorrectSteps : generatedCase.options;
    final correctAnswer = stepCase
        ? options.join(' -> ')
        : compareChoices(
            options,
            scenario: generatedCase.scenario,
            lawTopics: generatedCase.lawTopics,
          );

    return generatedCase.copyWith(
      options: options,
      correctAnswer: correctAnswer,
    );
  }

  int _scoreChoice(
    String choice, {
    required String scenario,
    required List<String> lawTopics,
  }) {
    final normalizedChoice = _normalize(choice);
    final context = _normalize('$scenario ${lawTopics.join(' ')}');
    var score = 0;

    const positiveKeywords = {
      'revisi': 8,
      'prosedur': 5,
      'tinjau': 5,
      'audit': 5,
      'investigasi': 5,
      'mediasi': 4,
      'bipartit': 6,
      'bayar': 6,
      'penuhi': 6,
      'pesangon': 6,
      'kompensasi': 5,
      'keselamatan': 5,
      'k3': 5,
      'objektif': 6,
      'non diskriminatif': 7,
      'tertulis': 4,
      'dokumentasi': 4,
      'konsultasi': 3,
    };

    const negativeKeywords = {
      'tolak': 7,
      'abaikan': 8,
      'paksa': 8,
      'sepihak': 8,
      'tanpa bayar': 9,
      'tanpa pesangon': 9,
      'phk langsung': 8,
      'lanjutkan tanpa': 7,
      'potong': 5,
      'sanksi': 3,
    };

    positiveKeywords.forEach((keyword, value) {
      if (normalizedChoice.contains(keyword)) score += value;
    });

    negativeKeywords.forEach((keyword, value) {
      if (normalizedChoice.contains(keyword)) score -= value;
    });

    if (context.contains('diskriminasi') || context.contains('usia')) {
      // Randomer scoring untuk variety
      if (normalizedChoice.contains('revisi')) score += 6; // turun dari 10
      if (normalizedChoice.contains('objektif')) score += 6;
      if (normalizedChoice == 'terima') score += 4; // naik dari 1
      if (normalizedChoice == 'tolak') score += 2; // naik dari -10
    }

    if (context.contains('memenuhi') || context.contains('sesuai') || context.contains('penuhi')) {
      if (normalizedChoice == 'terima') score += 8;
      if (normalizedChoice.contains('bayar')) score += 6;
    }

    if (context.contains('pelanggaran') || context.contains('tidak sesuai') || context.contains('melanggar')) {
      if (normalizedChoice == 'tolak') score += 8;
      if (normalizedChoice.contains('revisi')) score += 4;
    }

    if (context.contains('lembur') ||
        context.contains('upah') ||
        context.contains('keselamatan')) {
      if (normalizedChoice.contains('bayar')) score += 8;
      if (normalizedChoice.contains('lembur')) score += 6;
      if (normalizedChoice.contains('keselamatan')) score += 6;
      if (normalizedChoice.contains('mediasi')) score += 4;
      if (normalizedChoice.contains('abaikan')) score -= 10;
    }

    if (context.contains('phk') || context.contains('efisiensi')) {
      if (normalizedChoice.contains('bipartit')) score += 8;
      if (normalizedChoice.contains('pesangon')) score += 8;
      if (normalizedChoice.contains('tertulis')) score += 5;
      if (normalizedChoice.contains('sepihak')) score -= 10;
    }

    return score;
  }

  bool _sameOrder(List<String> userSteps, List<String> correctSteps) {
    for (var i = 0; i < correctSteps.length; i++) {
      if (userSteps[i] != correctSteps[i]) return false;
    }
    return true;
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  bool _containsAny(String text, List<String> keywords) {
  for (final keyword in keywords) {
    if (text.contains(_normalize(keyword))) {
      return true;
    }
  }
  return false;
}

String _findChoice(List<String> choices, String keyword) {
  for (final choice in choices) {
    if (_normalize(choice).contains(keyword)) {
      return choice;
    }
  }
  return choices.first;
}
}
