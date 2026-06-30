import '../repositories/ai_repository.dart';

class GenerateCase {
  final AiRepository repository;

  GenerateCase(this.repository);

  call() {
    return repository.generateCase();
  }
}