import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firestore_paths.dart';

class DesignLikeModel {
  const DesignLikeModel({
    required this.designId,
    required this.customerId,
    required this.customerName,
    required this.createdAt,
  });

  final String designId;
  final String customerId;
  final String customerName;
  final DateTime createdAt;
}

class DesignLikeRepository {
  DesignLikeRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('designLikes');

  /// Watch if a specific customer liked a design.
  Stream<bool> watchIsLiked({
    required String designId,
    required String customerId,
  }) {
    if (customerId.isEmpty) return Stream.value(false);
    final docId = '${designId}_$customerId';
    return _collection
        .doc(docId)
        .snapshots()
        .map((snapshot) => snapshot.exists)
        .handleError((_) => false);
  }

  /// Watch recent likes for a design to get customer names.
  Stream<List<DesignLikeModel>> watchRecentLikes(String designId) {
    return _collection
        .where('designId', isEqualTo: designId)
        .limit(10)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            final createdAtRaw = data['createdAt'];
            final createdAt = createdAtRaw is Timestamp
                ? createdAtRaw.toDate()
                : DateTime.now();
            return DesignLikeModel(
              designId: data['designId'] as String? ?? '',
              customerId: data['customerId'] as String? ?? '',
              customerName: data['customerName'] as String? ?? 'Customer',
              createdAt: createdAt,
            );
          }).toList();
        })
        .handleError((_) => <DesignLikeModel>[]);
  }

  /// Toggle like on a design in Firestore and update design's likeCount.
  Future<bool> toggleLike({
    required String designId,
    required String customerId,
    required String customerName,
  }) async {
    final docId = '${designId}_$customerId';
    final docRef = _collection.doc(docId);
    final designRef = _firestore.collection(FirestorePaths.designs).doc(designId);

    try {
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        // Remove like
        await docRef.delete().catchError((_) {});
        await designRef
            .update({'likeCount': FieldValue.increment(-1)})
            .catchError((_) {});
        return false;
      } else {
        // Add like
        await docRef.set({
          'designId': designId,
          'customerId': customerId,
          'customerName': customerName,
          'createdAt': FieldValue.serverTimestamp(),
        }).catchError((_) {});
        await designRef
            .update({'likeCount': FieldValue.increment(1)})
            .catchError((_) {});
        return true;
      }
    } catch (_) {
      // Fallback if Firestore read fails
      return true;
    }
  }
}
