import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leximpactai/data/datasource/ai_remote_datasource.dart';
import 'package:leximpactai/data/datasource/ai_repository_impl.dart';
import 'package:leximpactai/domain/usecases/evaluate_decision.dart';
import 'package:leximpactai/domain/usecases/generate_case.dart';

/// 🔌 DATASOURCE
final aiDatasourceProvider = Provider((ref) {
  return AiRemoteDatasource();
});

/// 🧠 REPOSITORY
final aiRepositoryProvider = Provider((ref) {
  return AiRepositoryImpl(ref.read(aiDatasourceProvider));
});

/// 🎯 USECASE → GENERATE CASE
final generateCaseProvider = FutureProvider((ref) {
  return GenerateCase(ref.read(aiRepositoryProvider)).call();
});

/// 🤖 USECASE → EVALUATE DECISION
final evaluateDecisionProvider =
    FutureProvider.family((ref, String answer) {
  return EvaluateDecision(ref.read(aiRepositoryProvider)).call(answer);
});