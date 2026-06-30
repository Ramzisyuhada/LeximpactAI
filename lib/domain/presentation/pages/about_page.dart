import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leximpactai/core/color/app_colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("Tentang Aplikasi"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),

            _buildDescription(),
            const SizedBox(height: 24),

            _buildVisionCard(),
            const SizedBox(height: 24),

            _buildFeatureCard(),
            const SizedBox(height: 24),

            _buildInfoCard(),
            const SizedBox(height: 24),

            _buildCTA()
          ],
        ),
      ),
    );
  }

  /// =========================
  /// 🧠 HEADER (UPGRADE)
  /// =========================
  Widget _buildHeader() {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.5),
              blurRadius: 20,
            )
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            "assets/logo/Logo.png", // 🔥 GANTI PATH LOGO KAMU
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
      ),

      const SizedBox(height: 16),

      Text(
        "LEXIMPACT AI",
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
      ),

      const SizedBox(height: 6),

      Text(
        "Smart HR Decision Simulator",
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: AppColors.mutedText,
          fontSize: 13,
        ),
      ),
    ],
  )
      .animate()
      .fadeIn(duration: 500.ms)
      .scale(begin: const Offset(0.8, 0.8));
}

  /// =========================
  /// 📖 DESCRIPTION
  /// =========================
  Widget _buildDescription() {
    return _glassCard(
      child: Text(
        "LEXIMPACT AI adalah platform pembelajaran berbasis simulasi yang membantu pengguna memahami pengambilan keputusan HR secara legal dan strategis. Dengan pendekatan gamifikasi dan AI, pengguna dapat belajar dari kasus nyata secara interaktif.",
        style: GoogleFonts.poppins(
          color: AppColors.mutedText,
          height: 1.6,
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
  }

  /// =========================
  /// 🎯 VISI / VALUE
  /// =========================
  Widget _buildVisionCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("🎯 Tujuan Aplikasi",
              style: GoogleFonts.poppins(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 10),

          _bullet("Meningkatkan pemahaman hukum ketenagakerjaan"),
          _bullet("Melatih pengambilan keputusan HR"),
          _bullet("Menyediakan simulasi realistis berbasis AI"),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle,
              size: 16, color: Colors.greenAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(color: AppColors.mutedText),
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// ⭐ FEATURE (UPGRADE UI)
  /// =========================
  Widget _buildFeatureCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("✨ Fitur Utama",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 10),

          _feature("🎮 Simulasi HR berbasis kasus nyata"),
          _feature("🤖 Analisis AI otomatis"),
          _feature("📚 Materi interaktif"),
          _feature("🧪 Quiz + scoring system"),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _feature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.poppins(color: AppColors.text),
      ),
    );
  }

  /// =========================
  /// 📊 INFO
  /// =========================
  Widget _buildInfoCard() {
    return _glassCard(
      child: Column(
        children: [
          _infoRow("Versi", "1.0.0"),
          _infoRow("Developer", "Ramzi Syuhada"),
          _infoRow("Platform", "Flutter"),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.poppins(color: AppColors.mutedText)),
          Text(value,
              style: GoogleFonts.poppins(color: AppColors.text)),
        ],
      ),
    );
  }

  /// =========================
  /// 🚀 CTA BUTTON
  /// =========================
  Widget _buildCTA() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text("Mulai Simulasi 🚀"),
      ),
    ).animate().fadeIn(delay: 600.ms).scale();
  }

  /// =========================
  /// 🔥 GLASS CARD COMPONENT
  /// =========================
  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
