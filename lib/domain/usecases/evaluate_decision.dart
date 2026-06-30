import '../repositories/ai_repository.dart';

class EvaluateDecision {
  final AiRepository repository;

  EvaluateDecision(this.repository);

  call(String answer) {
    return repository.evaluateDecision(answer);
  }
}