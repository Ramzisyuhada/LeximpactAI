import 'package:leximpactai/domain/model/generated_case.dart';

enum EvaluationStatus { benar, kurangTepat, salah }

/// Posisi satu langkah dalam susunan pemain dibanding urutan yang benar.
class StepCheck {
  final String step;

  /// Posisi 1-based dalam susunan pemain.
  final int userPosition;

  /// Posisi 1-based dalam urutan yang benar.
  final int correctPosition;

  const StepCheck({
    required this.step,
    required this.userPosition,
    required this.correctPosition,
  });

  bool get inPlace => userPosition == correctPosition;
}

class Evaluation {
  /// Skor 0-100.
  final int score;
  final EvaluationStatus status;

  // Kasus pilihan (Level 1 & 2).
  final String userAnswer;
  final String userExplanation;
  final String bestAnswer;
  final String bestExplanation;

  // Kasus susun langkah (Level 3).
  final List<String> correctSteps;
  final List<StepCheck> stepChecks;

  const Evaluation({
    required this.score,
    required this.status,
    this.userAnswer = '',
    this.userExplanation = '',
    this.bestAnswer = '',
    this.bestExplanation = '',
    this.correctSteps = const [],
    this.stepChecks = const [],
  });

  bool get isCorrect => status == EvaluationStatus.benar;

  bool get isStepEvaluation => correctSteps.isNotEmpty;

  List<StepCheck> get misplacedSteps =>
      stepChecks.where((check) => !check.inPlace).toList();

  String get statusLabel => switch (status) {
        EvaluationStatus.benar => 'BENAR',
        EvaluationStatus.kurangTepat => 'KURANG TEPAT',
        EvaluationStatus.salah => 'SALAH',
      };
}

/// Penilaian deterministik berdasarkan kunci di blueprint kasus lokal.
/// AI tidak ikut menentukan benar/salah maupun skor.
class RuleEngine {
  /// Skor minimum untuk status "kurang tepat" (di bawahnya "salah").
  static const int partialThreshold = 40;

  Evaluation evaluateChoice(GeneratedCase generatedCase, String userAnswer) {
    final blueprint = generatedCase.blueprint;
    final best = blueprint.bestOption;
    final chosen = blueprint.pilihan.where(
      (option) => _normalize(option.teks) == _normalize(userAnswer),
    );
    final score = chosen.isEmpty ? 0 : chosen.first.skor;

    return Evaluation(
      score: score,
      status: _statusFor(score),
      userAnswer: userAnswer,
      userExplanation: chosen.isEmpty ? '' : chosen.first.penjelasan,
      bestAnswer: best.teks,
      bestExplanation: best.penjelasan,
    );
  }

  /// Skor susunan langkah = 40% langkah di posisi tepat + 60% pasangan
  /// langkah yang urutannya relatif benar, sehingga susunan yang hampir
  /// benar tetap mendapat nilai parsial.
  Evaluation evaluateSteps(
    GeneratedCase generatedCase,
    List<String> userSteps,
  ) {
    final correctSteps = generatedCase.blueprint.langkah;
    final correctIndex = {
      for (var i = 0; i < correctSteps.length; i++)
        _normalize(correctSteps[i]): i,
    };

    final checks = <StepCheck>[];
    final userOrder = <int>[];
    for (var i = 0; i < userSteps.length; i++) {
      final index = correctIndex[_normalize(userSteps[i])];
      if (index == null) continue;
      userOrder.add(index);
      checks.add(StepCheck(
        step: userSteps[i],
        userPosition: i + 1,
        correctPosition: index + 1,
      ));
    }

    final n = correctSteps.length;
    final inPlace = checks.where((check) => check.inPlace).length;

    var concordant = 0;
    for (var i = 0; i < userOrder.length; i++) {
      for (var j = i + 1; j < userOrder.length; j++) {
        if (userOrder[i] < userOrder[j]) concordant++;
      }
    }
    final totalPairs = n * (n - 1) ~/ 2;

    final positionAccuracy = n == 0 ? 0.0 : inPlace / n;
    final orderAccuracy = totalPairs == 0 ? 0.0 : concordant / totalPairs;
    final score = (100 * (0.4 * positionAccuracy + 0.6 * orderAccuracy))
        .round()
        .clamp(0, 100);

    return Evaluation(
      score: score,
      status: _statusFor(score),
      correctSteps: correctSteps,
      stepChecks: checks,
    );
  }

  EvaluationStatus _statusFor(int score) {
    if (score >= 100) return EvaluationStatus.benar;
    if (score >= partialThreshold) return EvaluationStatus.kurangTepat;
    return EvaluationStatus.salah;
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
