import '../../domain/entities/decision_entity.dart';

class DecisionModel extends DecisionEntity {
  DecisionModel({
    required super.risk,
    required super.impact,
    required super.law,
    required super.recommendation,
  });
}