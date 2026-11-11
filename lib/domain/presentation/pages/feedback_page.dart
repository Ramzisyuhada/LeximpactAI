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
      "alasan": _extractList(clean, ["Alasan", "Kesalahan"]),
      "dasarHukum": _extractList(clean, ["Dasar Hukum"]),
      "saran": _extractList(clean, ["Saran"]),
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
        "alasan": _jsonList(json, const ["reason", "alasan", "kesalahan"]),
        "dasarHukum": _jsonList(
          json,
          const ["legal_basis", "dasar_hukum", "dasarhukum"],
        ),
        "saran": _jsonList(json, const ["suggestion", "suggestions", "saran"]),
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

  List<String> _extractList(String text, List<String> keys) {
    for (final key in keys) {
      final regex = RegExp(
        r'##\s*' + RegExp.escape(key) + r'\s*:?[ \t]*\n([\s\S]*?)(?=\n##\s|$)',
        caseSensitive: false,
      );

      final match = regex.firstMatch(text);
      if (match == null) continue;

      final section = match.group(1)!;

      final lines = section
          .split('\n')
          .map((e) => e.trim())
          .map((e) => e.replaceAll(RegExp(r'^[-•\d.]+\s*'), ''))
          .map((e) => e.replaceAll(RegExp(r'\s+'), ' '))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (lines.isNotEmpty) return lines;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final parsed = parseAIResult(aiResult);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// 1. LOGO BRAND HEADER (HORIZONTALLY CENTERED)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logo/logo_icon.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),

                    const SizedBox(height: 12),

                    /// 2. TITLE "ANALISIS AI" (HORIZONTALLY CENTERED)
                    Center(
                      child: Text(
                        "Analisis AI",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: AppColors.text,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ).animate().fadeIn().slideY(begin: -0.2),

                    const SizedBox(height: 6),

                    /// AI ENGINE BADGE (HORIZONTALLY CENTERED)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3156D3), Color(0xFF6366F1)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome, color: AppColors.aiGlow, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              "Powered by Leximpact AI Engine",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 20),

                    /// 3. DESKRIPSI SINGKAT & USER DECISION CARD (CENTERED)
                    _buildDecisionCard(),

                    const SizedBox(height: 20),

                    /// 4. AI ANALYSIS CONTENT (CARDS)
                    /// 📖 PENJELASAN / ALASAN
                    if (parsed["alasan"]!.isNotEmpty)
                      _buildAnalysisCard(
                        "📖 Penjelasan & Alasan",
                        parsed["alasan"]!.join(" "),
                        const Color(0xFFEF4444),
                        Icons.analytics_rounded,
                      ),

                    /// 📜 DASAR HUKUM (pasal dari data lokal)
                    if (parsed["dasarHukum"]!.isNotEmpty)
                      _buildListCard(
                        "📜 Dasar Hukum",
                        parsed["dasarHukum"]!,
                        const Color(0xFFF59E0B),
                        Icons.gavel_rounded,
                      ),

                    /// 💡 SARAN & REKOMENDASI
                    if (parsed["saran"]!.isNotEmpty)
                      _buildListCard(
                        "💡 Saran & Rekomendasi HR",
                        parsed["saran"]!,
                        const Color(0xFF10B981),
                        Icons.lightbulb_rounded,
                      ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            /// 5. CTA BUTTON (BOTTOM FIXED CONTAINER)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: _buildContinueButton(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 USER DECISION CARD (HORIZONTALLY CENTERED TEXT & BADGE)
  Widget _buildDecisionCard() {
    final isGood = aiResult.trimLeft().startsWith('✅');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGood
              ? [const Color(0xFF10B981), const Color(0xFF059669)]
              : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isGood ? Colors.green : Colors.red).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              // Baris pertama hasil analisis berisi status + skor,
              // mis. "✅ JAWABAN BENAR · Skor 100/100".
              aiResult.trimLeft().split('\n').first,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Keputusan Anda:\n\"$answer\"",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  /// 📊 ANALYSIS CARD
  Widget _buildAnalysisCard(
    String title,
    String content,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.border.withValues(alpha: 0.6), height: 1),
          const SizedBox(height: 12),
          MarkdownBody(
            data: content,
            styleSheet: MarkdownStyleSheet(
              p: GoogleFonts.poppins(
                color: AppColors.mutedText,
                fontSize: 14,
                height: 1.6,
              ),
              strong: GoogleFonts.poppins(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.15);
  }

  /// 💡 LIST CARD
  Widget _buildListCard(
    String title,
    List<String> items,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.border.withValues(alpha: 0.6), height: 1),
          const SizedBox(height: 12),
          ...items.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 18, color: color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        e,
                        style: GoogleFonts.poppins(
                          color: AppColors.mutedText,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.15);
  }

  /// 🚀 CONTINUE BUTTON
  Widget _buildContinueButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context, true),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          "Lanjutkan Simulasi 🚀",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }
}