import 'dart:math';

import 'package:leximpactai/domain/model/legal_document.dart';
import 'package:leximpactai/domain/service/knowledge_base.dart';

class RagHit {
  final LegalDocument document;
  final double score;

  /// `true` bila dokumen berasal dari referensi wajib blueprint kasus,
  /// bukan hasil pencarian.
  final bool pinned;

  const RagHit({
    required this.document,
    required this.score,
    this.pinned = false,
  });
}

class RagResult {
  final List<RagHit> hits;

  const RagResult(this.hits);

  bool get isRelevant => hits.isNotEmpty;

  /// Referensi bernomor untuk prompt AI berisi teks asli pasal (dan
  /// penjelasannya bila ada), mis. "[1] UU ... Pasal 5 — ...".
  String get context => [
        for (var i = 0; i < hits.length; i++) _contextEntry(i + 1, hits[i]),
      ].join('\n\n');

  static String _contextEntry(int number, RagHit hit) {
    final doc = hit.document;
    final penjelasan = doc.penjelasanExcerpt(500);
    return [
      '[$number] ${doc.citation} (${doc.judul}):',
      doc.excerpt(1500),
      if (penjelasan != null) 'Penjelasan: $penjelasan',
      if (doc.catatan != null) 'Catatan: ${doc.catatan}',
    ].join('\n');
  }
}

/// RAG lokal: mencari pasal relevan dari regulasi yang disimpan di HP
/// memakai BM25 (tanpa database dan tanpa embedding online).
///
/// Istilah hukum yang sama diseragamkan lewat [_synonyms] supaya
/// "pemutusan hubungan kerja" cocok dengan "PHK", "alih daya" dengan
/// "outsourcing", dst.
class RagService {
  static const double _k1 = 1.2;
  static const double _b = 0.75;

  /// Skor BM25 minimum agar hasil pencarian dianggap relevan.
  static const double _minScore = 2.0;

  /// Hasil tambahan harus minimal sebesar ini dibanding skor tertinggi.
  static const double _relativeCutoff = 0.5;

  final KnowledgeBase knowledgeBase;

  final List<Map<String, int>> _termFreqs = [];
  final List<int> _docLengths = [];
  final Map<String, int> _docFreq = {};
  double _avgDocLength = 1;

  RagService(this.knowledgeBase) {
    _buildIndex();
  }

  /// Mengambil referensi untuk sebuah kasus: dokumen [pinnedIds] dari
  /// blueprint selalu disertakan lebih dulu, lalu ditambah maksimal
  /// [maxExtra] pasal hasil pencarian [query] yang belum ada.
  RagResult retrieve({
    required String query,
    List<String> pinnedIds = const [],
    String? tahap,
    int maxExtra = 2,
    int maxTotal = 5,
  }) {
    final hits = <RagHit>[];
    final seen = <String>{};

    for (final id in pinnedIds) {
      final doc = knowledgeBase.documentById(id);
      if (doc != null && seen.add(doc.id)) {
        hits.add(RagHit(document: doc, score: 0, pinned: true));
      }
    }

    final ranked = search(query, tahap: tahap);
    final room = min(maxExtra, maxTotal - hits.length);
    if (ranked.isNotEmpty && room > 0) {
      final cutoff = max(_minScore, ranked.first.score * _relativeCutoff);
      hits.addAll(
        ranked
            .where((hit) => hit.score >= cutoff && seen.add(hit.document.id))
            .take(room),
      );
    }

    return RagResult(hits);
  }

  /// Pencarian BM25 murni, diurutkan dari skor tertinggi.
  List<RagHit> search(String query, {String? tahap, int topK = 5}) {
    final queryTerms = tokenize(query).toSet();
    if (queryTerms.isEmpty) return const [];

    final docs = knowledgeBase.documents;
    final hits = <RagHit>[];

    for (var i = 0; i < docs.length; i++) {
      var score = 0.0;
      final tf = _termFreqs[i];
      final lengthNorm = 1 - _b + _b * _docLengths[i] / _avgDocLength;

      for (final term in queryTerms) {
        final freq = tf[term];
        if (freq == null) continue;
        score += _idf(term) * (freq * (_k1 + 1)) / (freq + _k1 * lengthNorm);
      }

      if (score <= 0) continue;
      if (tahap != null && docs[i].tahap == tahap) score *= 1.15;
      hits.add(RagHit(document: docs[i], score: score));
    }

    hits.sort((a, b) => b.score.compareTo(a.score));
    return hits.take(topK).toList();
  }

  void _buildIndex() {
    for (final doc in knowledgeBase.documents) {
      // Topik (judul BAB/Bagian/Paragraf) diberi bobot dua kali.
      final tokens = [
        ...tokenize('${doc.pasal} ${doc.isi} ${doc.penjelasan ?? ''}'),
        ...tokenize(doc.judul),
        for (var i = 0; i < 2; i++) ...tokenize(doc.topik.join(' ')),
      ];

      final tf = <String, int>{};
      for (final token in tokens) {
        tf[token] = (tf[token] ?? 0) + 1;
      }
      for (final term in tf.keys) {
        _docFreq[term] = (_docFreq[term] ?? 0) + 1;
      }

      _termFreqs.add(tf);
      _docLengths.add(tokens.length);
    }

    if (_docLengths.isNotEmpty) {
      _avgDocLength =
          _docLengths.reduce((a, b) => a + b) / _docLengths.length;
    }
  }

  double _idf(String term) {
    final n = _termFreqs.length;
    final df = _docFreq[term] ?? 0;
    return log((n - df + 0.5) / (df + 0.5) + 1);
  }

  /// Frasa hukum → token kanonik yang ditambahkan ke teks.
  static const Map<String, String> _synonyms = {
    'pemutusan hubungan kerja': 'phk',
    'dipecat': 'phk',
    'pemecatan': 'phk',
    'memecat': 'phk',
    'alih daya': 'outsourcing',
    'penyedia jasa': 'outsourcing',
    'penyerahan sebagian pelaksanaan pekerjaan': 'outsourcing',
    'pemborongan pekerjaan': 'outsourcing',
    'keselamatan dan kesehatan kerja': 'k3',
    'keselamatan kerja': 'k3',
    'alat pelindung diri': 'apd',
    'perlindungan diri': 'apd',
    'helm': 'apd',
    'sabuk pengaman': 'apd',
    'tenaga kerja asing': 'tka',
    'rptka': 'tka',
    'perjanjian kerja waktu tertentu': 'pkwt',
    'kontrak': 'pkwt',
    'perjanjian kerja waktu tidak tertentu': 'pkwtt',
    'pekerja tetap': 'pkwtt',
    'karyawan tetap': 'pkwtt',
    'upah minimum': 'upahminimum',
    'umk': 'upahminimum',
    'ump': 'upahminimum',
    'serikat pekerja': 'serikat',
    'serikat buruh': 'serikat',
    'jaminan sosial': 'bpjs',
    'jamsostek': 'bpjs',
    'kecelakaan kerja': 'bpjs',
    'badan penyelenggara': 'bpjs',
    'mendaftarkan': 'bpjs',
    'mengundurkan diri': 'resign',
    'pengunduran diri': 'resign',
    'surat peringatan': 'peringatan',
    'kursi roda': 'disabilitas',
    'difabel': 'disabilitas',
    'kondisi fisik': 'disabilitas',
    'penyandang cacat': 'disabilitas',
    'melahirkan': 'hamil',
    'keguguran': 'hamil',
    'tidak masuk kerja': 'mangkir',
    'surat peringatan pertama': 'peringatan',
    'tanpa kabar': 'mangkir',
    'efisiensi': 'efisiensi',
    'restrukturisasi': 'efisiensi',
    'mesin otomatis': 'efisiensi',
    'perselisihan': 'bipartit',
    'sengketa': 'bipartit',
    'berunding': 'bipartit',
    'mogok': 'bipartit',
    'perjanjian kerja bersama': 'pkb',
    'tunjangan': 'upah',
    'lowongan': 'lowongan',
    'terlalu tua': 'diskriminasi',
    'karena usia': 'diskriminasi',
    'batas usia': 'diskriminasi',
    'usia maksimal': 'diskriminasi',
    'karena agama': 'diskriminasi',
    'karena gender': 'diskriminasi',
    'berusia': 'usia',
    'di bawah umur': 'anak',
    'berumur': 'usia',
    'diskriminasi': 'diskriminasi',
    'membedakan': 'diskriminasi',
  };

  static const Set<String> _stopwords = {
    'yang', 'dan', 'di', 'ke', 'dari', 'untuk', 'dengan', 'atau', 'dalam',
    'pada', 'ini', 'itu', 'adalah', 'sebagai', 'oleh', 'akan', 'juga',
    'telah', 'sudah', 'ada', 'bagi', 'para', 'setiap', 'secara', 'tersebut',
    'agar', 'hanya', 'lebih', 'dapat', 'harus', 'tidak', 'bila', 'jika',
    'apabila', 'serta', 'karena', 'atas', 'antara', 'hal', 'anda', 'saya',
    'kami', 'mereka', 'ia', 'nya', 'pt', 'sesuai', 'ingin', 'tanpa',
    'belum', 'masih', 'sedang', 'lalu', 'kemudian', 'apa', 'bagaimana',
    'kepada', 'paling', 'sebuah', 'seorang',
  };

  /// Tokenisasi teks Indonesia sederhana + ekspansi sinonim.
  static List<String> tokenize(String text) {
    final normalized = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (normalized.isEmpty) return const [];

    final tokens = <String>[];
    for (final word in normalized.split(' ')) {
      if (word.length < 2 || _stopwords.contains(word)) continue;
      tokens.add(_stem(word));
    }

    final padded = ' $normalized ';
    _synonyms.forEach((phrase, canonical) {
      if (padded.contains(' $phrase ')) tokens.add(canonical);
    });

    return tokens;
  }

  /// Stemming ringan: buang akhiran "-nya" yang paling sering muncul.
  static String _stem(String word) {
    if (word.length > 5 && word.endsWith('nya')) {
      return word.substring(0, word.length - 3);
    }
    return word;
  }
}
