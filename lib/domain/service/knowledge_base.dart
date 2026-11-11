import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:leximpactai/domain/model/case_blueprint.dart';
import 'package:leximpactai/domain/model/legal_document.dart';

/// Data regulasi dan bank kasus yang disimpan lokal di HP (assets).
class KnowledgeBase {
  static const regulationsAsset = 'assets/data/regulasi.json';
  static const casesAsset = 'assets/data/kasus.json';

  static KnowledgeBase? _cached;

  final List<LegalDocument> documents;
  final List<CaseBlueprint> cases;
  final Map<String, LegalDocument> _byId;

  KnowledgeBase({required this.documents, required this.cases})
      : _byId = {for (final doc in documents) doc.id: doc};

  factory KnowledgeBase.fromJsonStrings({
    required String regulationsJson,
    required String casesJson,
  }) {
    final regulations = jsonDecode(regulationsJson) as Map<String, dynamic>;
    final cases = jsonDecode(casesJson) as Map<String, dynamic>;

    return KnowledgeBase(
      documents: (regulations['dokumen'] as List)
          .map((e) => LegalDocument.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      cases: (cases['kasus'] as List)
          .map((e) => CaseBlueprint.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  /// Memuat data dari assets sekali, lalu memakai cache.
  static Future<KnowledgeBase> load() async {
    final cached = _cached;
    if (cached != null) return cached;

    final kb = KnowledgeBase.fromJsonStrings(
      regulationsJson: await rootBundle.loadString(regulationsAsset),
      casesJson: await rootBundle.loadString(casesAsset),
    );
    _cached = kb;
    return kb;
  }

  LegalDocument? documentById(String id) => _byId[id];

  List<CaseBlueprint> casesForLevel(int level) =>
      cases.where((c) => c.level == level).toList();
}
