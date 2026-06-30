import 'dart:convert';
import 'package:http/http.dart' as http;

class MistralService {
  final String apiKey = "WRZPeApzPupgXFip9EcvMfrt5Hk7OMTy";

  Future<String> generate(String prompt, {double temperature = 0.7}) async {
    final response = await http.post(
      Uri.parse("https://api.mistral.ai/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "model": "mistral-small",
        "messages": [
          {"role": "user", "content": prompt}
        ],
        "temperature": temperature
      }),
    );

    final data = jsonDecode(response.body);
    return data["choices"][0]["message"]["content"];
  }

  Future<List<double>> getEmbedding(String text) async {
    final response = await http.post(
      Uri.parse("https://api.mistral.ai/v1/embeddings"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "model": "mistral-embed",
        "input": text
      }),
    );

    final data = jsonDecode(response.body);

    return List<double>.from(data['data'][0]['embedding']);
  }
}
