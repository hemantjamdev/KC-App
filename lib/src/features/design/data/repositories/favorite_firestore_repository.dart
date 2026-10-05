import 'package:cloud_firestore/cloud_firestore.dart';

/// Repository for customer favorites stored in Firestore `favorites` collection.
class FavoriteFirestoreRepository {
  FavoriteFirestoreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Stream of favorited design IDs for a customer.
  Stream<List<String>> watchCustomerFavoriteIds(String customerId) {
    if (customerId.isEmpty) return Stream.value([]);
    return _firestore
        .collection('favorites')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => doc.data()['designId'] as String? ?? '')
              .where((id) => id.isNotEmpty)
              .toList();
        })
        .handleError((_) => <String>[]);
  }

  /// Add a design to customer's favorites.
  Future<void> addFavorite({
    required String customerId,
    required String designId,
  }) async {
    final docId = '${customerId}_$designId';
    try {
      await _firestore.collection('favorites').doc(docId).set({
        'id': docId,
        'customerId': customerId,
        'designId': designId,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Gracefully handle permission restriction
    }
  }

  /// Remove a design from customer's favorites.
  Future<void> removeFavorite({
    required String customerId,
    required String designId,
  }) async {
    final docId = '${customerId}_$designId';
    try {
      await _firestore.collection('favorites').doc(docId).delete();
    } catch (_) {
      // Gracefully handle permission restriction
    }
  }
}
