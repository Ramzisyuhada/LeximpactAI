import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:leximpactai/core/color/app_colors.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int score = 0;
  int currentIndex = 0;
  int? selectedIndex;
  bool answered = false;

  final questions = [
  {
    "q": "Manajemen sumber daya manusia adalah proses untuk memperoleh, mengembangkan, mempertahankan, dan melindungi tenaga kerja agar organisasi dapat mencapai tujuan secara…",
    "options": ["Administratif", "Efektif", "Formal", "Struktural"],
    "answer": 1
  },
  {
    "q": "Dalam organisasi modern keputusan HR tidak hanya berdampak pada efisiensi organisasi, tetapi juga pada…",
    "options": ["Hubungan sosial", "Kebijakan pemasaran", "Implikasi hukum", "Struktur organisasi"],
    "answer": 2
  },
  {
    "q": "Kesalahan dalam pengelolaan tenaga kerja dapat menimbulkan masalah berikut, kecuali…",
    "options": ["Sengketa hubungan industrial", "Pelanggaran hak pekerja", "Sanksi hukum bagi perusahaan", "Peningkatan produktivitas otomatis"],
    "answer": 3
  },
  {
    "q": "Hubungan kerja menurut UU No.13 Tahun 2003 memiliki tiga unsur utama, yaitu…",
    "options": ["Pekerjaan, upah, perintah", "Kontrak, jabatan, organisasi", "Pekerja, manajer, pimpinan", "Tugas, wewenang, tanggung jawab"],
    "answer": 0
  },
  {
    "q": "Hubungan kerja antara pekerja dan pengusaha didasarkan pada…",
    "options": ["Kesepakatan informal", "Perjanjian kerja", "Kebijakan perusahaan", "Hubungan sosial"],
    "answer": 1
  },
  {
    "q": "Siklus hubungan kerja dalam manajemen SDM terdiri dari…",
    "options": ["Recruitment, training, evaluation", "Planning, organizing, controlling", "Pre-employment, during employment, post-employment", "Hiring, supervising, retiring"],
    "answer": 2
  },
  {
    "q": "Tahap sebelum seseorang resmi bekerja dalam organisasi disebut…",
    "options": ["During employment", "Post employment", "Pre employment", "Work placement"],
    "answer": 2
  },
  {
    "q": "Berikut yang termasuk kegiatan dalam tahap pre-employment adalah…",
    "options": ["Penggajian", "Pemutusan hubungan kerja", "Rekrutmen dan seleksi", "Pensiun"],
    "answer": 2
  },
  {
    "q": "Perencanaan tenaga kerja termasuk dalam tahap…",
    "options": ["Post-employment", "During employment", "Pre-employment", "Industrial relation"],
    "answer": 2
  },
  {
    "q": "Prinsip kesempatan kerja yang sama diatur dalam…",
    "options": ["Pasal 5 UU No.13 Tahun 2003", "Pasal 77 UU No.13 Tahun 2003", "Pasal 150 UU No.13 Tahun 2003", "Pasal 156 UU No.13 Tahun 2003"],
    "answer": 0
  },
  {
    "q": "Hak mendapatkan perlakuan yang sama bagi tenaga kerja diatur dalam…",
    "options": ["Pasal 6 UU No.13 Tahun 2003", "Pasal 31 UU No.13 Tahun 2003", "Pasal 77 UU No.13 Tahun 2003", "Pasal 150 UU No.13 Tahun 2003"],
    "answer": 0
  },
  {
    "q": "Rekrutmen tenaga kerja diatur dalam…",
    "options": ["Pasal 31 UU No.13 Tahun 2003", "Pasal 88 UU No.13 Tahun 2003", "Pasal 79 UU No.13 Tahun 2003", "Pasal 150 UU No.13 Tahun 2003"],
    "answer": 0
  },
  {
    "q": "Penempatan tenaga kerja diatur dalam…",
    "options": ["Pasal 54 UU No.13 Tahun 2003", "Pasal 32 UU No.13 Tahun 2003", "Pasal 88 UU No.13 Tahun 2003", "Pasal 156 UU No.13 Tahun 2003"],
    "answer": 1
  },
  {
    "q": "Unsur perjanjian kerja diatur dalam…",
    "options": ["Pasal 77", "Pasal 54", "Pasal 79", "Pasal 150"],
    "answer": 1
  },
  {
    "q": "Tahap hubungan kerja ketika pekerja sudah bekerja di organisasi disebut…",
    "options": ["Post-employment", "During employment", "Pre-employment", "Industrial stage"],
    "answer": 1
  },
  {
    "q": "Pengaturan waktu kerja diatur dalam…",
    "options": ["Pasal 77 UU No.13 Tahun 2003", "Pasal 150 UU No.13 Tahun 2003", "Pasal 54 UU No.13 Tahun 2003", "Pasal 6 UU No.13 Tahun 2003"],
    "answer": 0
  },
  {
    "q": "Waktu istirahat pekerja diatur dalam…",
    "options": ["Pasal 56", "Pasal 79", "Pasal 31", "Pasal 150"],
    "answer": 1
  },
  {
    "q": "Ketentuan mengenai upah pekerja diatur dalam…",
    "options": ["Pasal 88", "Pasal 32", "Pasal 54", "Pasal 5"],
    "answer": 0
  },
  {
    "q": "Kebijakan pengupahan diatur dalam…",
    "options": ["Pasal 79", "Pasal 88", "Pasal 89", "Pasal 31"],
    "answer": 2
  },
  {
    "q": "Upah lembur diatur dalam…",
    "options": ["Pasal 77", "Pasal 78", "Pasal 79", "Pasal 80"],
    "answer": 1
  },
  {
    "q": "Undang-undang yang mengatur keselamatan kerja adalah…",
    "options": ["UU No.21 Tahun 2000", "UU No.13 Tahun 2003", "UU No.1 Tahun 1970", "UU No.2 Tahun 2004"],
    "answer": 2
  },
  {
    "q": "Undang-undang yang mengatur serikat pekerja adalah…",
    "options": ["UU No.21 Tahun 2000", "UU No.2 Tahun 2004", "UU No.40 Tahun 2004", "UU No.13 Tahun 2003"],
    "answer": 0
  },
  {
    "q": "Perselisihan hubungan industrial diatur dalam…",
    "options": ["UU No.1 Tahun 1970", "UU No.21 Tahun 2000", "UU No.2 Tahun 2004", "UU No.40 Tahun 2004"],
    "answer": 2
  },
  {
    "q": "Tahap hubungan kerja setelah hubungan kerja berakhir disebut…",
    "options": ["Post-employment", "Pre-employment", "During employment", "Industrial phase"],
    "answer": 0
  },
  {
    "q": "Contoh kondisi yang termasuk post-employment adalah…",
    "options": ["Rekrutmen", "Seleksi", "Pensiun", "Pelatihan"],
    "answer": 2
  },
  {
    "q": "Pemutusan hubungan kerja diatur dalam…",
    "options": ["Pasal 31", "Pasal 150", "Pasal 79", "Pasal 77"],
    "answer": 1
  },
  {
    "q": "Hak pekerja setelah PHK diatur dalam…",
    "options": ["Pasal 150", "Pasal 156", "Pasal 88", "Pasal 79"],
    "answer": 1
  },
  {
    "q": "Penyelesaian sengketa PHK dapat dilakukan melalui…",
    "options": [
      "Bipartit, mediasi, konsiliasi, pengadilan hubungan industrial",
      "Rapat direksi",
      "Keputusan HRD",
      "Keputusan sepihak perusahaan"
    ],
    "answer": 0
  },
  {
    "q": "Jika pekerja tidak diberikan alat pelindung saat bekerja dengan mesin berbahaya, maka perusahaan melanggar…",
    "options": ["UU serikat pekerja", "UU keselamatan kerja", "UU pengupahan", "UU hubungan industrial"],
    "answer": 1
  },
  {
    "q": "Prinsip utama dalam pengambilan keputusan HR adalah…",
    "options": [
      "Efisiensi organisasi saja",
      "Kepentingan manajemen",
      "Kesesuaian dengan hukum dan hak pekerja",
      "Keputusan pimpinan"
    ],
    "answer": 2
  },
];

  void answerQuestion(int index) async {
    if (answered) return;

    final correctIndex = questions[currentIndex]["answer"] as int;

    setState(() {
      selectedIndex = index;
      answered = true;

      if (index == correctIndex) {
        score += 10;
      } else {
        score -= 5;
        if (score < 0) score = 0; // 🔥 FIX: tidak minus
      }
    });

    /// ⏳ delay biar user lihat feedback
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      currentIndex++;
      if (currentIndex >= questions.length) {
        currentIndex = 0;
      }

      selectedIndex = null;
      answered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentIndex];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("Quiz Mode"),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildScore(),

            const SizedBox(height: 20),

            _buildQuestion(currentQuestion["q"] as String),

            const SizedBox(height: 20),

            ...(currentQuestion["options"] as List<String>)
                .asMap()
                .entries
                .map((e) => _buildOption(e.key, e.value))
                .toList(),
          ],
        ),
      ),
    );
  }

  /// ⭐ SCORE UI (UPGRADE)
  Widget _buildScore() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Score",
              style: TextStyle(color: AppColors.mutedText)),
          Text(
            "$score XP",
            style: const TextStyle(
              color: Colors.green,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.2);
  }

  /// ❓ QUESTION CARD (UPGRADE)
  Widget _buildQuestion(String text) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE9EFFF), Color(0xFFDCE7FF)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.text, fontSize: 16),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  /// 🎮 OPTION BUTTON (UPGRADE)
  Widget _buildOption(int index, String text) {
    final correctIndex = questions[currentIndex]["answer"] as int;

    Color bgColor = Colors.white;

    if (answered) {
      if (index == correctIndex) {
        bgColor = Colors.green;
      } else if (index == selectedIndex) {
        bgColor = Colors.red;
      }
    }

    return GestureDetector(
      onTap: () => answerQuestion(index),
      child: AnimatedContainer(
        duration: 300.ms,
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: AppColors.text),
              ),
            ),

            /// ✔ / ❌ icon
            if (answered)
              Icon(
                index == correctIndex
                    ? Icons.check_circle
                    : (index == selectedIndex
                        ? Icons.cancel
                        : null),
                color: Colors.white,
              )
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms)
        .slideX(begin: 0.2);
  }
}
