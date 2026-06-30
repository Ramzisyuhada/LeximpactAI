import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
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
          /// 🎨 BACKGROUND
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

          /// ✨ GLOW
          Positioned(top: -100, left: -100, child: _glowCircle(220)),
          Positioned(bottom: -120, right: -80, child: _glowCircle(260)),

          /// 🎮 CONTENT
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                /// 🎮 HUD
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(0.78),
                      border:
                          Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Level 1",
                            style: TextStyle(color: AppColors.text)),
                        Row(
                          children: const [
                            Icon(Icons.star, color: Colors.yellow),
                            SizedBox(width: 4),
                            Text("120 XP",
                                style: TextStyle(color: AppColors.text)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(),

                const SizedBox(height: 20),

                /// 🧠 TITLE
                const Text(
                  "LEXIMPACT AI",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                    letterSpacing: 2,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.3),

                const SizedBox(height: 8),

                /// SUBTITLE
                const Text(
                  "Legal Experience for HR Decision Impact",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.mutedText),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 20),

                /// 🤖 CHARACTER
                SizedBox(
                  height: 220,
                  child: Lottie.asset('assets/lottie/chatbot.json'),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .scale(
                      duration: 700.ms,
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                    )
                    .then(delay: 200.ms)
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.05, 1.05),
                      duration: 2.seconds,
                    )
                    .then()
                    .scale(
                      begin: const Offset(1.05, 1.05),
                      end: const Offset(1, 1),
                      duration: 2.seconds,
                    ),

                const SizedBox(height: 20),

                /// 🧠 STORY
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "Anda adalah HR Manager.\nSetiap keputusan yang Anda ambil memiliki dampak hukum bagi perusahaan dan karyawan.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.text, fontSize: 16),
                  ),
                ).animate().fadeIn(delay: 500.ms),

                const Spacer(),

                /// 🚀 BUTTON SIMULASI
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.6),
                          blurRadius: 30,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: GameButton(
                      text: "▶ MULAI SIMULASI",
                      onTap: () => context.go('/simulation'),
                    ),
                  ),
                )
                    .animate()
                    .scale(delay: 700.ms)
                    .fadeIn(),

                const SizedBox(height: 12),

                /// 🎯 MENU
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
_miniMenu("Materi", Icons.menu_book, "/materi"),
                    const SizedBox(width: 10),
_miniMenu("Kuis", Icons.quiz, "/quiz"),
                    const SizedBox(width: 10),
_miniMenu("Tentang", Icons.info, "/about"),                  ],
                ).animate().fadeIn(delay: 900.ms),

                const SizedBox(height: 30),
              ],
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
        color: AppColors.accent.withOpacity(0.15),
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

        /// 🌈 GLASS EFFECT
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.9),
            const Color(0xFFEAF1FF),
          ],
        ),

        border: Border.all(color: AppColors.border),

        /// 🔥 DEPTH
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 🎯 ICON
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

          /// TEXT
          Text(
            text,
            style: const TextStyle(
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
