import '../entities/case_entity.dart';
import '../entities/decision_entity.dart';

abstract class AiRepository {
  Future<CaseEntity> generateCase();
  Future<DecisionEntity> evaluateDecision(String answer);
}