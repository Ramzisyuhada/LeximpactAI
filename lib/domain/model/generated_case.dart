import 'dart:convert';

class GeneratedCase {
  final String scenario;
  final List<String> options;
  final String correctAnswer;
  final List<String> lawTopics;

  const GeneratedCase({
    required this.scenario,
    required this.options,
    required this.correctAnswer,
    required this.lawTopics,
  });

  factory GeneratedCase.fromJson(Map<String, dynamic> json) {
    return GeneratedCase(
      scenario: _readString(json, const ['scenario', 'kasus']),
      options: _readStringList(json, const ['options', 'pilihan', 'steps', 'langkah']),
      correctAnswer: _readString(
        json,
        const ['correctAnswer', 'correct_answer', 'jawabanBenar', 'jawaban_benar'],
      ),
      lawTopics: _readStringList(
        json,
        const ['lawTopics', 'law_topics', 'topikHukum', 'topik_hukum'],
      ),
    );
  }

  GeneratedCase copyWith({
    String? scenario,
    List<String>? options,
    String? correctAnswer,
    List<String>? lawTopics,
  }) {
    return GeneratedCase(
      scenario: scenario ?? this.scenario,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      lawTopics: lawTopics ?? this.lawTopics,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scenario': scenario,
      'options': options,
      'correctAnswer': correctAnswer,
      'lawTopics': lawTopics,
    };
  }

  String toJsonString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  String toLegacyText({bool asSteps = false}) {
    final buffer = StringBuffer()
      ..writeln('Kasus:')
      ..writeln(scenario)
      ..writeln();

    if (asSteps) {
      buffer.writeln('Langkah:');
      for (var i = 0; i < options.length; i++) {
        buffer.writeln('${i + 1}. ${options[i]}');
      }
    } else {
      buffer.writeln('Pilihan:');
      for (final option in options) {
        buffer.writeln('- $option');
      }
    }

    return buffer.toString().trim();
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      if (value is String) return value.trim();
      return value.toString().trim();
    }
    return '';
  }

  static List<String> _readStringList(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      if (value is List) {
        return value
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList();
      }
      if (value is String) {
        return value
            .split(RegExp(r'[,;\n]'))
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList();
      }
    }
    return const [];
  }
}
