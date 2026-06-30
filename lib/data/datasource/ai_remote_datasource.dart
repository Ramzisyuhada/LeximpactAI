import '../models/case_model.dart';
import '../models/decision_model.dart';

class AiRemoteDatasource {

  Future<CaseModel> generateCase() async {
    await Future.delayed(const Duration(seconds: 1));

    return CaseModel(
      description:
          "Seorang kandidat ditolak karena usia. Apakah ini melanggar hukum?",
      options: [
        "Terima kandidat",
        "Tolak kandidat",
        "Revisi prosedur"
      ],
    );
  }

  Future<DecisionModel> evaluateDecision(String answer) async {
    await Future.delayed(const Duration(seconds: 1));

    return DecisionModel(
      risk: "Berpotensi diskriminasi",
      impact: "Merugikan kandidat",
      law: "UU No 13 Tahun 2003",
      recommendation: "Gunakan asas objektif",
    );
  }
}