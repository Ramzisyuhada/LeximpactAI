import '../../domain/entities/case_entity.dart';
import '../../domain/entities/decision_entity.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasource/ai_remote_datasource.dart';

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDatasource datasource;

  AiRepositoryImpl(this.datasource);

  @override
  Future<CaseEntity> generateCase() {
    return datasource.generateCase();
  }

  @override
  Future<DecisionEntity> evaluateDecision(String answer) {
    return datasource.evaluateDecision(answer);
  }
}