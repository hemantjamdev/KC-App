import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firestore_paths.dart';
import '../../domain/models/boutique_model.dart';

/// Firestore repository for boutiques.
class BoutiqueFirestoreRepository {
  BoutiqueFirestoreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<BoutiqueModel>> watchBoutiques() {
    return _firestore
        .collection(FirestorePaths.boutiques)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(_fromFirestore).toList();
        })
        .handleError((_) => <BoutiqueModel>[]);
  }

  Future<List<BoutiqueModel>> getBoutiques() async {
    try {
      final snap = await _firestore.collection(FirestorePaths.boutiques).get();
      return snap.docs.map(_fromFirestore).toList();
    } catch (_) {
      return [];
    }
  }

  BoutiqueModel _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    OperatingHoursModel? opHours;
    if (data['operatingHours'] != null && data['operatingHours'] is Map) {
      opHours = OperatingHoursModel.fromMap(
        Map<String, dynamic>.from(data['operatingHours'] as Map),
      );
    } else {
      opHours = OperatingHoursModel.defaultSchedule;
    }

    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final todayName = dayNames[DateTime.now().weekday - 1];
    final todaySched = opHours.dailySchedules[todayName];

    String openingHoursStr;
    if (todaySched != null && todaySched.isOpen) {
      openingHoursStr = '${todaySched.openTime} to ${todaySched.closeTime}';
    } else {
      openingHoursStr = 'Closed Today';
    }

    return BoutiqueModel(
      id: data['id'] as String? ?? doc.id,
      name: data['name'] as String? ?? 'Kapada Creation',
      subtitle: data['subtitle'] as String? ?? '',
      phone: data['phone'] as String?,
      email: data['email'] as String?,
      address: data['address'] as String?,
      openingHours: openingHoursStr,
      operatingHours: opHours,
      description: data['description'] as String?,
      logoUrl: data['logoUrl'] as String? ?? data['photoUrl'] as String? ?? data['imageUrl'] as String?,
      establishedYear: data['establishedYear'] as String? ?? data['sinceYear'] as String? ?? '2022',
      isActive: data['isActive'] as bool? ?? true,
    );
  }
}
