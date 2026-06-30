import 'package:leximpactai/domain/model/simulation_case.dart';
import 'package:leximpactai/domain/utils/generated_case_parser.dart';

class CaseParser {
  static SimulationCase parse(String rawText) {
    final generatedCase = GeneratedCaseParser.tryParseJson(rawText);
    if (generatedCase != null) {
      return SimulationCase(
        scenario: generatedCase.scenario,
        options: generatedCase.options,
      );
    }

    /// =========================
    /// 🔥 CLEAN TEXT
    /// =========================
    final clean = rawText
        .replaceAll("**", "")
        .replaceAll("\r", "")
        .trim();

    String scenario = "";
    List<String> options = [];

    /// =========================
    /// 🧠 SCENARIO (ANTI ✔ MASUK)
    /// =========================
    String temp = clean;

    temp = temp.split("✔").first;
    temp = temp.split(RegExp(r"\d+\.")).first;

    scenario = temp
        .replaceAll(RegExp(r"Kasus:", caseSensitive: false), "")
        .replaceAll(RegExp(r"Pilihan:", caseSensitive: false), "")
        .replaceAll("\n", " ")
        .replaceAll(RegExp(r"\s+"), " ")
        .trim();

    /// =========================
    /// 🔥 DETECT LEVEL
    /// =========================
    final lower = clean.toLowerCase();

    final isLevel1 =
        clean.contains("✔ Terima") &&
        clean.contains("✔ Tolak") &&
        clean.contains("✔ Revisi");

    final isLevel3 = RegExp(r"\d+\.").hasMatch(clean);

    final isLevel2 = clean.contains("✔") && !isLevel3 && !isLevel1;

    /// =========================
/// 🔵 LEVEL 3 (LANGKAH SUPER FIX)
/// =========================
if (RegExp(r"\d+\.\s").hasMatch(clean)) {
  final matches = RegExp(r"\d+\.\s*").allMatches(clean).toList();

  for (int i = 0; i < matches.length; i++) {
    final start = matches[i].end;
    final end = (i + 1 < matches.length)
        ? matches[i + 1].start
        : clean.length;

    String step = clean.substring(start, end);

    /// 🔥 CLEAN TOTAL
    step = step
        .replaceAll("\n", " ")
        .replaceAll(RegExp(r"\s+"), " ")
        .trim();

    /// 🔥 FILTER BIAR GA MASUK SAMPAH
    if (step.length > 15 && !step.toLowerCase().contains("kasus")) {
      options.add(step);
    }
  }
}

    /// =========================
    /// 🟢 LEVEL 1 (FIXED)
    /// =========================
    else if (isLevel1) {
      options = ["Terima", "Tolak", "Revisi prosedur"];
    }

    /// =========================
    /// 🟡 LEVEL 2 (✔)
    /// =========================
    else if (isLevel2) {
      final matches = RegExp(r"✔\s*([^✔]+)").allMatches(clean);

      for (var m in matches) {
        String text = m.group(1)!;

        text = text
            .replaceAll("\n", " ")
            .replaceAll(RegExp(r"\s+"), " ")
            .trim();

        if (text.length > 5) {
          options.add(text);
        }
      }
    }

    /// =========================
    /// 🚨 FALLBACK
    /// =========================
    if (options.isEmpty) {
      options = [
        "Ambil keputusan sesuai prosedur",
        "Tinjau ulang kebijakan",
        "Lakukan mediasi"
      ];
    }

    /// =========================
    /// 🔥 LIMIT
    /// =========================
    if (options.length > 7) {
      options = options.take(7).toList();
    }

    return SimulationCase(
      scenario: scenario,
      options: options,
    );
  }
}
