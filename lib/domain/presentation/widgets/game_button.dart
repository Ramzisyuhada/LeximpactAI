import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:leximpactai/core/color/app_colors.dart';

class GameButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const GameButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  double scale = 1;
  bool isPressed = false;

  void _onTapDown(TapDownDetails _) {
    setState(() {
      scale = 0.92;
      isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails _) async {
    setState(() {
      scale = 1.05; // 🔥 bounce up
      isPressed = false;
    });

    await Future.delayed(80.ms);

    setState(() => scale = 1);

    widget.onTap();
  }

  void _onCancel() {
    setState(() {
      scale = 1;
      isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onCancel,
      child: AnimatedScale(
        duration: 120.ms,
        curve: Curves.easeOut,
        scale: scale,
        child: AnimatedContainer(
          duration: 120.ms,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),

            /// 🌈 GRADIENT LEBIH HIDUP
            gradient: LinearGradient(
              colors: isPressed
                  ? [AppColors.secondary, AppColors.accent]
                  : [AppColors.accent, AppColors.secondary],
            ),

            /// 🔥 SHADOW DINAMIS
            boxShadow: [
              if (!isPressed)
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.6),
                  blurRadius: 25,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
            ],
          ),

          child: Stack(
            alignment: Alignment.center,
            children: [
              /// ✨ GLOW ANIMATED
              if (!isPressed)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fadeIn(duration: 1.seconds)
                      .fadeOut(duration: 1.seconds),
                ),

              /// ⚡ FLASH EFFECT (tap feel)
              if (isPressed)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),

              /// TEXT
              Text(
                widget.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(
          duration: 400.ms,
          curve: Curves.easeOutBack,
        );
  }
}