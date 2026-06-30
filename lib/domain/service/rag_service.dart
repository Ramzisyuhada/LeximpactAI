import 'package:supabase_flutter/supabase_flutter.dart';
import 'mistral_service.dart';

class RagResult {
  final String context;
  final bool isRelevant;

  RagResult({required this.context, required this.isRelevant});
}

class RagService {
  final supabase = Supabase.instance.client;
  final mistral = MistralService();

  /// Ambang batas similarity minimal supaya context dianggap relevan.
  /// Sesuaikan dengan skala yang dikembalikan RPC `match_documents`
  /// (misal cosine similarity 0..1).
  static const double _minSimilarity = 0.75;

  Future<RagResult> getContextChecked(String query) async {
    try {
      final embedding = await mistral.getEmbedding(query);

      final response = await supabase.rpc(
        'match_documents',
        params: {
          'match_count': 3,
          'query_embedding': embedding,
        },
      );

      final data = response as List;

      if (data.isEmpty) {
        return RagResult(context: "", isRelevant: false);
      }

      // Asumsi: RPC mengembalikan kolom 'similarity' per baris.
      final isRelevant = data.any((e) {
        final sim = e['similarity'];
        return sim != null && (sim as num) >= _minSimilarity;
      });

      final context = data.map((e) => e['content']).join("\n\n");

      return RagResult(context: context, isRelevant: isRelevant);
    } catch (e) {
      print("RAG ERROR: $e");
      return RagResult(context: "", isRelevant: false);
    }
  }

  Future<String> getContext(String query) async {
    final result = await getContextChecked(query);
    return result.context;
  }
}