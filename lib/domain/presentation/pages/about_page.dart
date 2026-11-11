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
            _buildTeamCard(
              icon: "🎓",
              title: "Tim Peneliti",
              members: const [
                _Member(
                  "Rahman Hasim, S.IP., M.Si.",
                  "Prodi Administrasi Negara Universitas Terbuka",
                ),
                _Member(
                  "Gunawan Wiradharma, S.Pd., S.I.Kom., M.Si., M.Hum.",
                  "Prodi Ilmu Komunikasi FHISIP Universitas Terbuka",
                ),
                _Member(
                  "Mario Aditya Prasetyo, S.Pd., S.I.Kom.",
                  "Pascasarjana Ilmu Komunikasi FISIP Universitas Indonesia",
                ),
              ],
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 24),
            _buildTeamCard(
              icon: "💻",
              title: "Tim Pengembang",
              members: const [
                _Member("Zaenab Diah Febriani"),
                _Member("Eriel Dantes"),
                _Member("Galih Ashari R."),
                _Member("Ramzi Syuhada"),
              ],
            ).animate().fadeIn(delay: 550.ms),
            const SizedBox(height: 24),
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildCTA(context),
          ],
        ),
      ),
    );
  }

  /// 🧠 HEADER
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF3156D3), Color(0xFF6366F1)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
              )
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              "assets/logo/logo_icon.png",
              width: 90,
              height: 90,
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

  /// 📖 DESCRIPTION
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

  /// 🎯 VISI / VALUE
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

  /// ⭐ FEATURE
  Widget _buildFeatureCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("✨ Fitur Utama",
              style: GoogleFonts.poppins(
                color: AppColors.text,
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

  /// 📊 INFO
  Widget _buildInfoCard() {
    return _glassCard(
      child: Column(
        children: [
          _infoRow("Versi", "1.0.0"),
          _infoRow("Platform", "Flutter"),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  /// 👥 TEAM
  Widget _buildTeamCard({
    required String icon,
    required String title,
    required List<_Member> members,
  }) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$icon $title",
              style: GoogleFonts.poppins(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 10),
          for (var i = 0; i < members.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "${i + 1}",
                      style: GoogleFonts.poppins(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          members[i].name,
                          style: GoogleFonts.poppins(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        if (members[i].affiliation != null)
                          Text(
                            members[i].affiliation!,
                            style: GoogleFonts.poppins(
                              color: AppColors.mutedText,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
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

  /// 🚀 CTA BUTTON
  Widget _buildCTA(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text("Kembali ke Home 🚀"),
      ),
    ).animate().fadeIn(delay: 600.ms).scale();
  }

  /// 🔥 GLASS CARD COMPONENT
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

/// Anggota tim yang ditampilkan di halaman Tentang.
class _Member {
  final String name;
  final String? affiliation;

  const _Member(this.name, [this.affiliation]);
}
