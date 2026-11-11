/// Pilihan jawaban untuk kasus Level 1 & 2 beserta skor dan penjelasannya.
class CaseOption {
  final String teks;
  final int skor;
  final String penjelasan;

  const CaseOption({
    required this.teks,
    required this.skor,
    required this.penjelasan,
  });

  factory CaseOption.fromJson(Map<String, dynamic> json) {
    return CaseOption(
      teks: json['teks'] as String,
      skor: (json['skor'] as num).toInt(),
      penjelasan: json['penjelasan'] as String,
    );
  }
}

/// Kerangka kasus simulasi yang disimpan lokal di `assets/data/kasus.json`.
///
/// Kunci jawaban, skor, dan pasal acuan ditentukan di sini, bukan oleh AI,
/// sehingga penilaian selalu konsisten. AI hanya menulis ulang narasi
/// [skenario] dengan mempertahankan [fakta].
class CaseBlueprint {
  final String id;
  final int level;
  final String tahap;
  final String judul;
  final List<String> topik;
  final String skenario;
  final List<String> fakta;
  final String pertanyaan;

  /// Diisi untuk kasus pilihan (Level 1 & 2).
  final List<CaseOption> pilihan;

  /// Diisi untuk kasus susun langkah (Level 3), dalam urutan yang benar.
  final List<String> langkah;

  /// ID [LegalDocument] yang menjadi dasar hukum kasus.
  final List<String> refs;

  const CaseBlueprint({
    required this.id,
    required this.level,
    required this.tahap,
    required this.judul,
    required this.topik,
    required this.skenario,
    required this.fakta,
    required this.pertanyaan,
    required this.pilihan,
    required this.langkah,
    required this.refs,
  });

  factory CaseBlueprint.fromJson(Map<String, dynamic> json) {
    return CaseBlueprint(
      id: json['id'] as String,
      level: (json['level'] as num).toInt(),
      tahap: json['tahap'] as String? ?? '',
      judul: json['judul'] as String,
      topik: List<String>.from(json['topik'] as List? ?? const []),
      skenario: json['skenario'] as String,
      fakta: List<String>.from(json['fakta'] as List? ?? const []),
      pertanyaan: json['pertanyaan'] as String? ?? '',
      pilihan: (json['pilihan'] as List? ?? const [])
          .map((e) => CaseOption.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      langkah: List<String>.from(json['langkah'] as List? ?? const []),
      refs: List<String>.from(json['refs'] as List? ?? const []),
    );
  }

  bool get isStepCase => langkah.isNotEmpty;

  CaseOption get bestOption =>
      pilihan.reduce((a, b) => b.skor > a.skor ? b : a);
}
