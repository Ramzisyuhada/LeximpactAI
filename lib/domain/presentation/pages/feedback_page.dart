import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leximpactai/core/color/app_colors.dart';

class AIFeedbackPage extends StatelessWidget {
  final String answer;
  final String aiResult;

  const AIFeedbackPage({
    super.key,
    required this.answer,
    required this.aiResult,
  });
// String extractBestAnswer(String text) {
//   final regex = RegExp(r"Jawaban Terbaik:\s*(.*)");

//   final match = regex.firstMatch(text);
//   return match != null ? match.group(1)!.trim() : "-";
// }
  /// 🔥 LIST → PARAGRAF
  String listToParagraph(List<String> items) {
    if (items.isEmpty) return "";
    if (items.length == 1) return items.first;
    if (items.length == 2) return "${items[0]} dan ${items[1]}";

    final last = items.last;
    final rest = items.sublist(0, items.length - 1);
    return "${rest.join(', ')}, dan $last";
  }

  /// 🔥 PARSER FINAL
  Map<String, List<String>> parseAIResult(String text) {
    final jsonResult = _parseJsonAIResult(text);
    if (jsonResult != null) return jsonResult;

    final clean = text.replaceAll("**", "");

    return {
      "risiko": _extractList(clean, ["Risiko", "Risiko Hukum"]),
      "dampak": _extractList(clean, ["Dampak", "Dampak Sosial"]),
      "rekomendasi": _extractList(clean, ["Rekomendasi"]),
    };
  }

  Map<String, List<String>>? _parseJsonAIResult(String text) {
    final jsonText = _extractJsonObject(text);
    if (jsonText == null) return null;

    try {
      final decoded = jsonDecode(jsonText);
      if (decoded is! Map) return null;

      final json = Map<String, dynamic>.from(decoded);
      return {
        "risiko": _jsonList(json, const ["risk", "risiko"]),
        "dampak": _jsonList(json, const ["impact", "dampak"]),
        "rekomendasi": _jsonList(
          json,
          const ["recommendation", "recommendations", "rekomendasi"],
        ),
      };
    } catch (_) {
      return null;
    }
  }

  String? _extractJsonObject(String text) {
    final clean = text
        .replaceAll(RegExp(r"```json", caseSensitive: false), "")
        .replaceAll("```", "")
        .trim();
    final start = clean.indexOf("{");
    final end = clean.lastIndexOf("}");

    if (start == -1 || end == -1 || end <= start) return null;
    return clean.substring(start, end + 1);
  }

  List<String> _jsonList(Map<String, dynamic> json, List<String> keys) {
    dynamic value;

    for (final key in keys) {
      if (json.containsKey(key)) {
        value = json[key];
        break;
      }
    }

    if (value == null) return [];
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return value
        .toString()
        .split(RegExp(r"[;\n]"))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  /// 🔥 EXTRACT LIST CLEAN
  List<String> _extractList(String text, List<String> keys) {
    for (var key in keys) {
      final regex = RegExp(
        "$key[:\\s]*([\\s\\S]*?)(?=\\n[A-Z][a-zA-Z ]+:|\\Z)",
        caseSensitive: false,
      );

      final match = regex.firstMatch(text);

      if (match != null) {
        String section = match.group(1)!;

        final lines = section
            .split('\n')
            .map((e) => e.trim())
            .map((e) => e.replaceAll(RegExp(r'^[-•\d.]+'), ''))
            .map((e) => e.replaceAll(RegExp(r'\s+'), ' '))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        return lines;
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final parsed = parseAIResult(aiResult);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),

              _buildDecisionCard(),

              const SizedBox(height: 20),

              Expanded(
                child: ListView(
                  children: [
                    /// ⚖️ RISIKO → PARAGRAF
                    if (parsed["risiko"]!.isNotEmpty)
                      _buildAnalysisCard(
                        "⚖️ Risiko Hukum",
                        listToParagraph([...parsed["risiko"]!]),
                        Colors.redAccent,
                      ),

                    /// 📊 DAMPAK → PARAGRAF
                    if (parsed["dampak"]!.isNotEmpty)
                      _buildAnalysisCard(
                        "📊 Dampak Sosial",
                        listToParagraph([...parsed["dampak"]!]),
                        Colors.orangeAccent,
                      ),

                    /// 💡 REKOMENDASI → LIST ✔
                    if (parsed["rekomendasi"]!.isNotEmpty)
                      _buildListCard(
                        "💡 Rekomendasi",
                        parsed["rekomendasi"]!,
                        Colors.greenAccent,
                        Icons.lightbulb,
                      ),

                    /// 🤖 FULL AI
                    _buildAnalysisCard(
                      "🤖 Analisis Lengkap AI",
                      aiResult,
                      Colors.blueAccent,
                    ),
                  ],
                ),
              ),

              _buildContinueButton(context)
            ],
          ),
        ),
      ),
    );
  }

  /// 🧠 HEADER
  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.psychology, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          "Analisis AI",
          style: GoogleFonts.poppins(
            color: AppColors.text,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    )
        .animate()
        .fadeIn()
        .slideX(begin: -0.2);
  }

  /// 🎯 USER DECISION
  Widget _buildDecisionCard() {
    final isGood = answer.toLowerCase().contains("revisi");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGood
              ? [Colors.green.shade400, Colors.green.shade700]
              : [Colors.red.shade400, Colors.red.shade700],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        "Keputusan Anda: $answer",
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  /// 📊 ANALYSIS CARD
  Widget _buildAnalysisCard(
      String title, String content, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(Icons.analytics, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                MarkdownBody(
                  data: content,
                  styleSheet:  MarkdownStyleSheet(
                    p: TextStyle(color: AppColors.mutedText, height: 1.6),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  /// 💡 LIST CARD
  Widget _buildListCard(
    String title,
    List<String> items,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...items.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle,
                        size: 16, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e,
                        style: const TextStyle(
                          color: AppColors.mutedText,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  /// 🚀 BUTTON
  Widget _buildContinueButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context,true),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text("Lanjutkan"),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }
}
