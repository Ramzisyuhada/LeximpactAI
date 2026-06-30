import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leximpactai/domain/model/simulation_case.dart';
import 'package:leximpactai/domain/presentation/pages/feedback_page.dart';
import 'package:leximpactai/domain/service/simulation_ai_service.dart';
import 'package:leximpactai/domain/utils/case_parser.dart';
import 'package:leximpactai/core/color/app_colors.dart';

class SimulationPage extends StatefulWidget {
  const SimulationPage({super.key});

  @override
  State<SimulationPage> createState() => _SimulationPageState();
}

class _SimulationPageState extends State<SimulationPage> {
  SimulationCase? simCase;
  bool isLoading = true;
  String? selectedAnswer;
  int level = 1;

  final int maxLevel = 3;

  /// 🔥 LEVEL 3
  List<String> steps = [];

  @override
  void initState() {
    super.initState();
    loadCase();
  }

  /// 🔥 LOAD CASE
  void loadCase() async {
    try {
      final ai = SimulationAIService();
      String result;

      if (level == 1) {
        result = await ai.generateCase();
        print(result);
      } else if (level == 2) {
        result = await ai.generateCaseLevel2();
                print(result);

      } else {
        result = await ai.generateCaseLevel3();
        print(result);
      }

      final parsed = CaseParser.parse(result);

      setState(() {
        simCase = parsed;

        /// 🔥 FIX LEVEL 3 (FILTER + SHUFFLE)
        if (level == 3) {
          steps = parsed.options
              .where((e) => e.length < 120)
              .toList();

          steps.shuffle();
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String getLevelTitle() {
    switch (level) {
      case 1:
        return "Recruitment";
      case 2:
        return "PHK";
      case 3:
        return "Strategic HR 🔥";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = level / maxLevel;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildProgress(progress),
              const SizedBox(height: 20),
              _buildScenarioCard(),
              const SizedBox(height: 24),

              /// 🎮 CONTENT (SCROLLABLE)
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: isLoading
                      ? const SizedBox.shrink()
                      : (level == 3
                          ? _buildReorderableSteps()
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: (simCase?.options ?? [])
                                  .map((e) => _buildOption(e))
                                  .toList(),
                            )),
                ),
              ),

              const SizedBox(height: 16),
              _buildNextButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔙 HEADER (FIX TOTAL)
  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            context.go('/');
          },
          child: const Icon(Icons.arrow_back, color: AppColors.text),
        ),
        const SizedBox(width: 12),
        Text(
          "Simulasi HR",
          style: GoogleFonts.poppins(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        )
      ],
    ).animate().fadeIn().slideX(begin: -0.2);
  }

  /// 📊 PROGRESS
  Widget _buildProgress(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Level $level • ${getLevelTitle()}",
          style: GoogleFonts.poppins(color: AppColors.mutedText),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.border,
            valueColor:
                const AlwaysStoppedAnimation(Color(0xFF6366F1)),
          ),
        ),
      ],
    );
  }

  /// 📄 SCENARIO
  Widget _buildScenarioCard() {
    if (isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE9EFFF), Color(0xFFDCE7FF)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: MarkdownBody(
        data: simCase?.scenario ?? "",
        styleSheet:  MarkdownStyleSheet(
          p: TextStyle(
            color: AppColors.text,
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.3);
  }

  /// 🎮 OPTION
  Widget _buildOption(String text) {
    final isSelected = selectedAnswer == text;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => selectedAnswer = text);
      },
      child: AnimatedContainer(
        duration: 300.ms,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6366F1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? Colors.transparent : AppColors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.gavel,
                color: isSelected ? Colors.white : AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : AppColors.text,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.2);
  }

  /// 🎮 DRAG GAME
  Widget _buildReorderableSteps() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Susun strategi terbaik 🔥",
          style: GoogleFonts.poppins(
            color: Colors.deepOrange,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return GestureDetector(
            onLongPress: () {
              // Visual feedback untuk drag
              HapticFeedback.mediumImpact();
            },
            child: Draggable<int>(
              data: index,
              feedback: Material(
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.drag_handle,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          step,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              child: DragTarget<int>(
                onAcceptWithDetails: (details) {
                  setState(() {
                    final fromIndex = details.data;
                    if (fromIndex != index) {
                      final item = steps.removeAt(fromIndex);
                      steps.insert(index, item);
                    }
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: candidateData.isNotEmpty
                          ? const Color(0xFFE9EFFF)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: candidateData.isNotEmpty
                            ? const Color(0xFF6366F1)
                            : AppColors.border,
                        width: candidateData.isNotEmpty ? 2 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.drag_handle,
                          color: candidateData.isNotEmpty
                              ? const Color(0xFF6366F1)
                              : AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            step,
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 13,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  /// 🚀 NEXT BUTTON (FIX TOTAL)
  Widget _buildNextButton() {
    final enabled =
        (level == 3 && steps.isNotEmpty) ||
        (level != 3 && selectedAnswer != null);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled
            ? () async {
                final ai = SimulationAIService();

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                );

                final result = level == 3
                    ? await ai.analyzeLevel3(
                        scenario: simCase!.scenario,
                        userAnswer: steps.join(" → "),
                      )
                    : await ai.analyze(
                        scenario: simCase!.scenario,
                        userAnswer: selectedAnswer!,
                      );

                Navigator.pop(context);

                final goNext = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AIFeedbackPage(
                      answer: level == 3
                          ? "Strategi disusun"
                          : selectedAnswer!,
                      aiResult: result,
                    ),
                  ),
                );

                /// 🔥 FIX LOOP + FINAL NAVIGATION
                if (goNext == true || goNext == null) {
                  if (level < maxLevel) {
                    setState(() {
                      level++;
                      selectedAnswer = null;
                      isLoading = true;
                    });
                    loadCase();
                  } else {
                    showGeneralDialog(
  context: context,
  barrierDismissible: false,
  barrierLabel: "",
  barrierColor: AppColors.primary.withOpacity(0.22),

  transitionDuration: const Duration(milliseconds: 400),

  pageBuilder: (_, __, ___) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// 🌫 BACKDROP BLUR
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white.withOpacity(0.35),
            ),

            /// 🎉 MAIN CARD
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xFFE8EEFF)],
                ),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.4),
                    blurRadius: 40,
                    spreadRadius: 2,
                  )
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// 🏆 ANIMATED ICON
                  TweenAnimationBuilder(
                    tween: Tween(begin: 0.8, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFF59E0B),
                                Color(0xFFFBBF24)
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.7),
                                blurRadius: 25,
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.workspace_premium,
                            size: 42,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  /// 🎉 TITLE
                  Text(
                    "MISSION COMPLETE 🎉",
                    style: GoogleFonts.poppins(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// 📄 DESC
                  Text(
                    "Kamu berhasil menyelesaikan semua level simulasi HR.\n\nKeputusanmu telah dianalisis oleh AI.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: AppColors.mutedText,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// 📊 PROGRESS BAR (FAKE XP)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Progress",
                        style: GoogleFonts.poppins(
                          color: AppColors.mutedText,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: 1,
                          minHeight: 8,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation(
                              Color(0xFF22C55E)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// 🚀 BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.go('/');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 12,
                      ),
                      child: const Text(
                        "Kembali ke Home",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// 🔁 SECONDARY BUTTON
                  // TextButton(
                  //   onPressed: () {
                  //     Navigator.pop(context);
                  //     // reload simulation
                  //   },
                  //   child: const Text(
                  //     "Main Lagi",
                  //     style: TextStyle(color: Colors.white54),
                  //   ),
                  // )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  },

  /// ✨ ANIMATION MASUK
  transitionBuilder: (_, anim, __, child) {
    return Transform.scale(
      scale: Curves.easeOutBack.transform(anim.value),
      child: Opacity(
        opacity: anim.value,
        child: child,
      ),
    );
  },
);
                  }
                }
              }
            : null,
        child: const Text("Analisis AI"),
      ),
    );
  }
}
