import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/firebase/firestore_paths.dart';

/// Repository managing FCM device tokens in Firestore for authenticated customers.
class DeviceTokenRepository {
  DeviceTokenRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> registerToken({
    required String customerId,
    String? firebaseUid,
    required String token,
  }) async {
    try {
      final query = await _firestore
          .collection(FirestorePaths.deviceTokens)
          .where('customerId', isEqualTo: customerId)
          .where('token', isEqualTo: token)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        await doc.reference.update({
          'isActive': true,
          'lastSeenAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        final id = const Uuid().v4();
        await _firestore.collection(FirestorePaths.deviceTokens).doc(id).set({
          'id': id,
          'customerId': customerId,
          'firebaseUid': firebaseUid,
          'token': token,
          'platform': 'android',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastSeenAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {
      // Silently catch registration failure
    }
  }

  Future<void> deactivateToken(String token) async {
    try {
      final query = await _firestore
          .collection(FirestorePaths.deviceTokens)
          .where('token', isEqualTo: token)
          .get();

      final batch = _firestore.batch();
      for (final doc in query.docs) {
        batch.update(doc.reference, {
          'isActive': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (_) {}
  }
}
