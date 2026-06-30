import 'dart:convert';

import 'package:leximpactai/domain/model/generated_case.dart';

class GeneratedCaseParser {
  static GeneratedCase parse(
    String rawText, {
    required List<String> fallbackOptions,
    required List<String> fallbackLawTopics,
    bool stepCase = false,
  }) {
    final jsonCase = tryParseJson(rawText);
    if (jsonCase != null) {
      return _withFallbacks(
        jsonCase,
        fallbackOptions: fallbackOptions,
        fallbackLawTopics: fallbackLawTopics,
      );
    }

    return _withFallbacks(
      _parseLegacyText(rawText, stepCase: stepCase),
      fallbackOptions: fallbackOptions,
      fallbackLawTopics: fallbackLawTopics,
    );
  }

  static GeneratedCase? tryParseJson(String rawText) {
    final jsonText = _extractJsonObject(rawText);
    if (jsonText == null) return null;

    try {
      final decoded = jsonDecode(jsonText);
      if (decoded is! Map) return null;
      return GeneratedCase.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  static GeneratedCase _parseLegacyText(
    String rawText, {
    required bool stepCase,
  }) {
    final clean = rawText.replaceAll('**', '').replaceAll('\r', '').trim();
    final scenario = _extractScenario(clean);
    final options = stepCase ? _extractSteps(clean) : _extractOptions(clean);

    return GeneratedCase(
      scenario: scenario,
      options: options,
      correctAnswer: '',
      lawTopics: const [],
    );
  }

  static GeneratedCase _withFallbacks(
    GeneratedCase generatedCase, {
    required List<String> fallbackOptions,
    required List<String> fallbackLawTopics,
  }) {
    final scenario = generatedCase.scenario.trim().isNotEmpty
        ? generatedCase.scenario.trim()
        : 'Kasus HR ketenagakerjaan Indonesia.';

    return generatedCase.copyWith(
      scenario: scenario,
      options: generatedCase.options.isNotEmpty
          ? generatedCase.options
          : fallbackOptions,
      lawTopics: generatedCase.lawTopics.isNotEmpty
          ? generatedCase.lawTopics
          : fallbackLawTopics,
    );
  }

  static String? _extractJsonObject(String rawText) {
    final clean = rawText
        .replaceAll(RegExp(r'```json', caseSensitive: false), '')
        .replaceAll('```', '')
        .trim();

    try {
      final decoded = jsonDecode(clean);
      if (decoded is Map<String, dynamic>) return clean;
    } catch (_) {
      // Continue with object extraction below.
    }

    final start = clean.indexOf('{');
    final end = clean.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return null;
    return clean.substring(start, end + 1);
  }

  static String _extractScenario(String clean) {
    final match = RegExp(
      r'Kasus\s*:\s*([\s\S]*?)(?=\n\s*(Pilihan|Langkah)\s*:|\z)',
      caseSensitive: false,
    ).firstMatch(clean);

    if (match != null) {
      return _collapse(match.group(1) ?? '');
    }

    var scenario = clean
        .split(RegExp(r'\n\s*(Pilihan|Langkah)\s*:', caseSensitive: false))
        .first;

    scenario = scenario
        .split(RegExp(r'\n\s*(?:[-*]|\d+[.)])\s+'))
        .first
        .replaceAll(RegExp(r'Kasus\s*:', caseSensitive: false), '');

    return _collapse(scenario);
  }

  static List<String> _extractOptions(String clean) {
    final section = _extractSection(clean, 'Pilihan') ?? clean;
    final lines = section.split('\n');
    final options = <String>[];

    for (final line in lines) {
      final option = _cleanListItem(line);
      if (option.length > 2 && !_looksLikeHeading(option)) {
        options.add(option);
      }
    }

    return _dedupe(options);
  }

  static List<String> _extractSteps(String clean) {
    final section = _extractSection(clean, 'Langkah') ?? clean;
    final matches = RegExp(r'(?:^|\n)\s*\d+[.)]\s*(.+)').allMatches(section);
    final steps = matches
        .map((match) => _collapse(match.group(1) ?? ''))
        .where((step) => step.length > 2)
        .toList();

    if (steps.isNotEmpty) return _dedupe(steps);

    return _extractOptions(section);
  }

  static String? _extractSection(String clean, String heading) {
    final match = RegExp(
      '$heading\\s*:\\s*([\\s\\S]*)',
      caseSensitive: false,
    ).firstMatch(clean);

    return match?.group(1);
  }

  static String _cleanListItem(String line) {
    var item = line.trim();
    if (item.isEmpty) return '';

    final checkMark = String.fromCharCode(0x2714);
    final mojibakeCheckMark = String.fromCharCodes([0x00E2, 0x0153, 0x201D]);

    for (final marker in [checkMark, mojibakeCheckMark]) {
      if (item.startsWith(marker)) {
        item = item.substring(marker.length).trim();
      }
    }

    item = item
        .replaceFirst(RegExp(r'^(?:[-*]|\d+[.)]|[A-Za-z][.)])\s*'), '')
        .trim();

    return _collapse(item);
  }

  static List<String> _dedupe(List<String> values) {
    final seen = <String>{};
    final result = <String>[];

    for (final value in values) {
      final key = value.toLowerCase();
      if (seen.add(key)) result.add(value);
    }

    return result;
  }

  static bool _looksLikeHeading(String text) {
    final lower = text.toLowerCase();
    return lower == 'kasus' ||
        lower == 'pilihan' ||
        lower == 'langkah' ||
        lower.startsWith('format') ||
        lower.startsWith('aturan');
  }

  static String _collapse(String value) {
    return value.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
