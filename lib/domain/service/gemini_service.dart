import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiException implements Exception {
  final String message;
  GeminiException(this.message);

  @override
  String toString() => 'GeminiException: $message';
}

/// Klien Google Gemini API.
///
/// API key TIDAK ditulis di kode. Key disuntikkan saat build:
///   flutter build apk --dart-define-from-file=secrets.json
/// dengan `secrets.json` (diabaikan git) berisi `{"GEMINI_API_KEY": "..."}`.
/// Tanpa key, [generate] melempar [GeminiException] dan simulasi otomatis
/// memakai narasi serta penjelasan bawaan.
class GeminiService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  static const String _model = "gemini-3.5-flash";
  static const Duration _timeout = Duration(seconds: 30);

  bool get isConfigured => _apiKey.isNotEmpty;

  /// Mengirim prompt ke Gemini. Bila [jsonMode] aktif, model diminta
  /// mengembalikan objek JSON valid.
  Future<String> generate(
    String prompt, {
    double temperature = 0.7,
    bool jsonMode = false,
  }) async {
    if (!isConfigured) {
      throw GeminiException('GEMINI_API_KEY belum diisi saat build');
    }

    final response = await http
        .post(
          Uri.parse(
            "https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent",
          ),
          headers: {
            "Content-Type": "application/json",
            "x-goog-api-key": _apiKey,
          },
          body: jsonEncode({
            "contents": [
              {
                "role": "user",
                "parts": [
                  {"text": prompt}
                ],
              }
            ],
            "generationConfig": {
              "temperature": temperature,
              if (jsonMode) "responseMimeType": "application/json",
            },
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw GeminiException('HTTP ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final candidates = data["candidates"] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw GeminiException('Respons kosong: ${response.body}');
    }

    final parts = candidates[0]["content"]?["parts"] as List?;
    final text = (parts ?? const [])
        .map((p) => (p as Map)["text"] ?? '')
        .join()
        .trim();
    if (text.isEmpty) {
      throw GeminiException('Teks kosong: ${response.body}');
    }
    return text;
  }
}
