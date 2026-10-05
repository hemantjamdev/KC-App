import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firestore_paths.dart';
import '../../domain/models/category_model.dart';

/// Firestore repository for managing categories.
class CategoryFirestoreRepository {
  CategoryFirestoreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static final List<CategoryModel> predefinedCategories = [
    CategoryModel(
      id: 'cat_seasonal',
      boutiqueId: 'boutique_01',
      name: 'Seasonal',
      slug: 'seasonal',
      description: 'Curated seasonal edits for every weather and occasion',
      sortOrder: 1,
      isActive: true,
      isSystem: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    CategoryModel(
      id: 'cat_new_arrivals',
      boutiqueId: 'boutique_01',
      name: 'New Arrivals',
      slug: 'new-arrivals',
      description: 'Freshly stitched couture and designer arrivals',
      sortOrder: 2,
      isActive: true,
      isSystem: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    CategoryModel(
      id: 'cat_festive',
      boutiqueId: 'boutique_01',
      name: 'Festive',
      slug: 'festive',
      description: 'Royal festive attire & bridal celebration outfits',
      sortOrder: 3,
      isActive: true,
      isSystem: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
  ];

  /// Live stream of categories from Firestore.
  /// If Firestore has documents, emits exact live Firestore data.
  Stream<List<CategoryModel>> watchCategories(String boutiqueId) {
    return _firestore
        .collection(FirestorePaths.categories)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return predefinedCategories;
          }
          final list = snapshot.docs.map(_fromFirestore).toList();
          list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          return list;
        })
        .handleError((_) => predefinedCategories);
  }

  Future<void> createCategory(CategoryModel category) async {
    await _firestore
        .collection(FirestorePaths.categories)
        .doc(category.id)
        .set(_toFirestore(category, isCreate: true));
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _firestore
        .collection(FirestorePaths.categories)
        .doc(category.id)
        .update(_toFirestore(category, isCreate: false));
  }

  Future<void> setCategoryActiveStatus(String categoryId, bool isActive) async {
    await _firestore
        .collection(FirestorePaths.categories)
        .doc(categoryId)
        .update({
          'isActive': isActive,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  CategoryModel _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final createdAtRaw = data['createdAt'];
    final createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : DateTime.now();

    final updatedAtRaw = data['updatedAt'];
    final updatedAt = updatedAtRaw is Timestamp
        ? updatedAtRaw.toDate()
        : DateTime.now();

    final id = data['id'] as String? ?? doc.id;
    final slug = data['slug'] as String? ?? '';
    final isSys = (data['isSystem'] as bool?) ??
        (id.contains('seasonal') ||
            id.contains('new_arrivals') ||
            id.contains('festive') ||
            slug == 'seasonal' ||
            slug == 'new-arrivals' ||
            slug == 'festive');

    return CategoryModel(
      id: id,
      boutiqueId: data['boutiqueId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      slug: slug,
      description: data['description'] as String?,
      imageUrl: data['imageUrl'] as String?,
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isSystem: isSys,
    );
  }

  Map<String, dynamic> _toFirestore(
    CategoryModel category, {
    required bool isCreate,
  }) {
    return {
      'id': category.id,
      'boutiqueId': category.boutiqueId,
      'name': category.name,
      'slug': category.slug,
      'description': category.description,
      'imageUrl': category.imageUrl,
      'sortOrder': category.sortOrder,
      'isActive': category.isActive,
      'isSystem': category.isSystem,
      'updatedAt': FieldValue.serverTimestamp(),
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
