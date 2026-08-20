import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leximpactai/core/color/app_colors.dart';
import 'package:leximpactai/domain/presentation/widgets/game_button.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🎨 BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF7F9FF), Color(0xFFE6EEFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// 🌌 BACKGROUND ANIMATION
          Positioned.fill(
            child: Opacity(
              opacity: 0.035,
              child: Lottie.asset(
                'assets/lottie/chatbot.json',
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// ✨ GLOW DECORATIONS
          Positioned(top: -100, left: -100, child: _glowCircle(220)),
          Positioned(bottom: -120, right: -80, child: _glowCircle(260)),

          /// 🎮 CONTENT (SCROLLABLE & RESPONSIVE)
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  /// 🎮 HUD (LEVEL & XP)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withValues(alpha: 0.85),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.stars, color: AppColors.primary, size: 18),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Level 1",
                              style: GoogleFonts.poppins(
                                color: AppColors.text,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                "120 XP",
                                style: GoogleFonts.poppins(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 20),

                  /// 🖼️ LEXIMPACT AI BRAND LOGO & TITLE
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        // Logo Icon Image
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.asset(
                              'assets/logo/logo_icon.png',
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

                        const SizedBox(height: 14),

                        // Title Wordmark
                        Text(
                          "LEXIMPACT AI",
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                            letterSpacing: 2.0,
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                        const SizedBox(height: 6),

                        // Subtitle / Tagline
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Legal Experience for HR Decision Impact",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ).animate().fadeIn(delay: 350.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// 🤖 CHARACTER ANIMATION
                  SizedBox(
                    height: 180,
                    child: Lottie.asset('assets/lottie/chatbot.json'),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scale(
                        duration: 700.ms,
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1, 1),
                      )
                      .then(delay: 200.ms)
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.04, 1.04),
                        duration: 2.seconds,
                      )
                      .then()
                      .scale(
                        begin: const Offset(1.04, 1.04),
                        end: const Offset(1, 1),
                        duration: 2.seconds,
                      ),

                  const SizedBox(height: 16),

                  /// 🧠 STORY / ROLE CARD
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      "Anda adalah HR Manager.\nSetiap keputusan yang Anda ambil memiliki dampak hukum bagi perusahaan dan karyawan.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: AppColors.text,
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 24),

                  /// 🚀 BUTTON SIMULASI
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.5),
                            blurRadius: 25,
                            spreadRadius: 1,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: GameButton(
                        text: "▶ MULAI SIMULASI",
                        onTap: () => context.go('/simulation'),
                      ),
                    ),
                  ).animate().scale(delay: 700.ms).fadeIn(),

                  const SizedBox(height: 20),

                  /// 🎯 MINI MENU
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _miniMenu("Materi", Icons.menu_book_rounded, "/materi"),
                      const SizedBox(width: 12),
                      _miniMenu("Kuis", Icons.quiz_rounded, "/quiz"),
                      const SizedBox(width: 12),
                      _miniMenu("Tentang", Icons.info_outline_rounded, "/about"),
                    ],
                  ).animate().fadeIn(delay: 900.ms),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✨ GLOW
  Widget _glowCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accent.withValues(alpha: 0.15),
      ),
    ).animate().scale(duration: 4.seconds).fadeIn();
  }

  /// 🎯 MINI MENU
  Widget _miniMenu(String text, IconData icon, String route) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: AnimatedContainer(
        duration: 200.ms,
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.9),
              const Color(0xFFEAF1FF),
            ],
          ),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: AppColors.primary,
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  duration: 2.seconds,
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                ),
            const SizedBox(height: 6),
            Text(
              text,
              style: GoogleFonts.poppins(
                color: AppColors.text,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(
          duration: 300.ms,
          curve: Curves.easeOutBack,
        );
  }
}
