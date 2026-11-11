/// Satu pasal peraturan yang disimpan lokal di `assets/data/regulasi.json`
/// (dibangkitkan dari PDF oleh `tools/build_regulasi.py`) dan dipakai
/// sebagai sumber RAG.
class LegalDocument {
  final String id;
  final String sumber;
  final String pasal;
  final String judul;

  /// Tahap siklus kerja: `pre`, `during`, atau `post` (employment).
  final String tahap;
  final List<String> topik;

  /// Teks asli pasal dari PDF peraturan.
  final String isi;

  /// Penjelasan pasal dari bagian PENJELASAN peraturan, opsional.
  final String? penjelasan;

  /// Catatan perubahan regulasi (mis. diubah UU Cipta Kerja), opsional.
  final String? catatan;

  const LegalDocument({
    required this.id,
    required this.sumber,
    required this.pasal,
    required this.judul,
    required this.tahap,
    required this.topik,
    required this.isi,
    this.penjelasan,
    this.catatan,
  });

  factory LegalDocument.fromJson(Map<String, dynamic> json) {
    return LegalDocument(
      id: json['id'] as String,
      sumber: json['sumber'] as String,
      pasal: json['pasal'] as String,
      judul: json['judul'] as String,
      tahap: json['tahap'] as String? ?? '',
      topik: List<String>.from(json['topik'] as List? ?? const []),
      isi: json['isi'] as String,
      penjelasan: json['penjelasan'] as String?,
      catatan: json['catatan'] as String?,
    );
  }

  /// Contoh: "UU No. 13 Tahun 2003 Pasal 78".
  String get citation => '${sumber.split(' tentang ').first} $pasal';

  /// Potongan [isi] untuk tampilan/prompt; teks pasal asli bisa sangat
  /// panjang (mis. Pasal 1 berisi seluruh definisi).
  String excerpt(int maxChars) => _truncate(isi, maxChars);

  String? penjelasanExcerpt(int maxChars) =>
      penjelasan == null ? null : _truncate(penjelasan!, maxChars);

  static String _truncate(String text, int maxChars) {
    if (text.length <= maxChars) return text;
    final cut = text.lastIndexOf(' ', maxChars);
    return '${text.substring(0, cut > 0 ? cut : maxChars)} …';
  }
}
