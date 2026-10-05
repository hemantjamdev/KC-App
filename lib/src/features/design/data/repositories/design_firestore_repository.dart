import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firestore_paths.dart';
import '../../domain/models/design_model.dart';

/// Firestore repository for managing customer design catalogue.
class DesignFirestoreRepository {
  DesignFirestoreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Watch active designs for a boutique.
  Stream<List<DesignModel>> watchDesigns(String boutiqueId) {
    return _firestore
        .collection(FirestorePaths.designs)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map(_fromFirestore).toList();
          final filtered = (boutiqueId.isNotEmpty && boutiqueId != 'boutique_01')
              ? list
                  .where((d) =>
                      d.boutiqueId == boutiqueId || d.boutiqueId.isEmpty)
                  .toList()
              : list;
          filtered.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          return filtered;
        })
        .handleError((_) => <DesignModel>[]);
  }

  /// Fetch single design by ID.
  Future<DesignModel?> getDesignById(String designId) async {
    final doc = await _firestore
        .collection(FirestorePaths.designs)
        .doc(designId)
        .get();
    if (!doc.exists) return null;
    return _fromFirestore(doc);
  }

  /// Fetch multiple designs by list of IDs (e.g. for Favorites).
  Future<List<DesignModel>> getDesignsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final chunks = <List<String>>[];
    for (var i = 0; i < ids.length; i += 30) {
      chunks.add(ids.sublist(i, i + 30 > ids.length ? ids.length : i + 30));
    }

    final results = <DesignModel>[];
    for (final chunk in chunks) {
      final snapshot = await _firestore
          .collection(FirestorePaths.designs)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      results.addAll(snapshot.docs.map(_fromFirestore));
    }
    return results;
  }

  /// Create a design (admin/catalog sync).
  Future<void> createDesign(DesignModel design) async {
    await _firestore
        .collection(FirestorePaths.designs)
        .doc(design.id)
        .set(_toFirestore(design, isCreate: true));
  }

  /// Update an existing design.
  Future<void> updateDesign(DesignModel design) async {
    await _firestore
        .collection(FirestorePaths.designs)
        .doc(design.id)
        .update(_toFirestore(design, isCreate: false));
  }

  /// Upsert availability per branch.
  Future<void> upsertAvailability({
    required String boutiqueId,
    required String branchId,
    required String designId,
    required String status,
  }) async {
    final docId = '${branchId}_$designId';
    await _firestore
        .collection(FirestorePaths.designAvailability)
        .doc(docId)
        .set({
          'boutiqueId': boutiqueId,
          'branchId': branchId,
          'designId': designId,
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  DesignModel _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final createdAtRaw = data['createdAt'];
    final createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : DateTime.now();

    final updatedAtRaw = data['updatedAt'];
    final updatedAt = updatedAtRaw is Timestamp
        ? updatedAtRaw.toDate()
        : DateTime.now();

    return DesignModel(
      id: data['id'] as String? ?? doc.id,
      boutiqueId: data['boutiqueId'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      slug: data['slug'] as String? ?? '',
      shortDescription: data['shortDescription'] as String?,
      description: data['description'] as String?,
      thumbnailUrl: data['thumbnailUrl'] as String?,
      imageUrls: List<String>.from(data['imageUrls'] as List? ?? []),
      tags: List<String>.from(data['tags'] as List? ?? []),
      searchKeywords: List<String>.from(data['searchKeywords'] as List? ?? []),
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: createdAt,
      updatedAt: updatedAt,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      colors: List<String>.from(data['colors'] as List? ?? []),
      sizes: List<String>.from(data['sizes'] as List? ?? []),
      likeCount: (data['likeCount'] as num?)?.toInt() ?? 0,
      favoriteCount: (data['favoriteCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> _toFirestore(
    DesignModel design, {
    required bool isCreate,
  }) {
    return {
      'id': design.id,
      'boutiqueId': design.boutiqueId,
      'categoryId': design.categoryId,
      'name': design.name,
      'slug': design.slug,
      'shortDescription': design.shortDescription,
      'description': design.description,
      'thumbnailUrl': design.thumbnailUrl,
      'imageUrls': design.imageUrls,
      'tags': design.tags,
      'searchKeywords': design.searchKeywords,
      'sortOrder': design.sortOrder,
      'isActive': design.isActive,
      'price': design.price,
      'colors': design.colors,
      'sizes': design.sizes,
      'likeCount': design.likeCount,
      'favoriteCount': design.favoriteCount,
      'updatedAt': FieldValue.serverTimestamp(),
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
