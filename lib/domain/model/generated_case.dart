import 'package:leximpactai/domain/model/case_blueprint.dart';

/// Kasus yang siap dimainkan: blueprint lokal + narasi skenario
/// (hasil tulis ulang AI, atau narasi bawaan blueprint jika AI gagal).
class GeneratedCase {
  final CaseBlueprint blueprint;
  final String scenario;

  /// Urutan pilihan/langkah yang ditampilkan ke pemain (sudah diacak).
  final List<String> options;

  /// `true` bila [scenario] ditulis ulang oleh AI.
  final bool aiScenario;

  const GeneratedCase({
    required this.blueprint,
    required this.scenario,
    required this.options,
    this.aiScenario = false,
  });

  int get level => blueprint.level;
  String get title => blueprint.judul;
  String get question => blueprint.pertanyaan;
  bool get isStepCase => blueprint.isStepCase;
}
