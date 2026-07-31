import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firestore_paths.dart';
import '../../domain/models/notification_model.dart';

/// Firestore repository for customer notifications and read state.
class NotificationFirestoreRepository {
  NotificationFirestoreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<NotificationModel>> watchCustomerNotifications({String? customerUid}) {
    return _firestore
        .collection(FirestorePaths.notifications)
        .where('status', isEqualTo: 'published')
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          final list = snapshot.docs
              .map(_fromFirestore)
              .where((n) {
                // Exclude Admin-only notifications
                if (n.audienceType.name == 'admins') {
                  return false;
                }
                if (n.expiresAt != null && n.expiresAt!.isBefore(now)) {
                  return false;
                }
                if (n.scheduledAt != null && n.scheduledAt!.isAfter(now)) {
                  return false;
                }
                final isGeneral = n.audienceType == NotificationAudienceType.allBoutiqueCustomers ||
                    n.audienceType.name == 'allCustomers' ||
                    n.customerIds.contains('all') ||
                    n.customerIds.isEmpty;
                final isTargeted = customerUid != null &&
                    customerUid.isNotEmpty &&
                    n.customerIds.contains(customerUid);
                return isGeneral || isTargeted;
              })
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<void> createNotification(NotificationModel notification) async {
    await _firestore
        .collection(FirestorePaths.notifications)
        .doc(notification.id)
        .set(_toFirestore(notification, isCreate: true));
  }

  Future<void> updateNotification(NotificationModel notification) async {
    await _firestore
        .collection(FirestorePaths.notifications)
        .doc(notification.id)
        .update(_toFirestore(notification, isCreate: false));
  }

  Future<void> markAsRead(String notificationId, String customerUid) async {
    final docId = '${notificationId}_$customerUid';
    await _firestore
        .collection(FirestorePaths.notificationReads)
        .doc(docId)
        .set({
          'id': docId,
          'notificationId': notificationId,
          'uid': customerUid,
          'customerId': customerUid,
          'readAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  NotificationModel _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final typeStr = data['type'] as String? ?? 'general';
    final type = NotificationType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => NotificationType.general,
    );

    final statusStr = data['status'] as String? ?? 'draft';
    final status = NotificationStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => NotificationStatus.draft,
    );

    final audienceStr =
        data['audienceType'] as String? ?? data['audience'] as String? ?? 'allBoutiqueCustomers';
    final audience = NotificationAudienceType.values.firstWhere(
      (a) => a.name == audienceStr,
      orElse: () => NotificationAudienceType.allBoutiqueCustomers,
    );

    final relTypeStr = data['relatedEntityType'] as String?;
    NotificationDestinationType? relatedEntityType;
    if (relTypeStr != null && relTypeStr.isNotEmpty) {
      relatedEntityType = NotificationDestinationType.values.firstWhere(
        (e) => e.name == relTypeStr,
        orElse: () => NotificationDestinationType.none,
      );
    }

    final createdAtRaw = data['createdAt'];
    final createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : DateTime.now();

    final updatedAtRaw = data['updatedAt'];
    final updatedAt = updatedAtRaw is Timestamp
        ? updatedAtRaw.toDate()
        : DateTime.now();

    final publishedAtRaw = data['publishedAt'];
    final publishedAt = publishedAtRaw is Timestamp
        ? publishedAtRaw.toDate()
        : null;

    final scheduledAtRaw = data['scheduledAt'];
    final scheduledAt = scheduledAtRaw is Timestamp
        ? scheduledAtRaw.toDate()
        : null;

    final expiresAtRaw = data['expiresAt'];
    final expiresAt = expiresAtRaw is Timestamp
        ? expiresAtRaw.toDate()
        : null;

    final rawCustomerIds = data['customerIds'] as List? ?? data['targetCustomerUids'] as List? ?? [];

    return NotificationModel(
      id: data['id'] as String? ?? doc.id,
      boutiqueId: data['boutiqueId'] as String? ?? '',
      branchId: data['branchId'] as String?,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      type: type,
      audienceType: audience,
      customerIds: List<String>.from(rawCustomerIds),
      relatedEntityType: relatedEntityType,
      relatedEntityId: data['relatedEntityId'] as String? ?? data['targetId'] as String?,
      status: status,
      scheduledAt: scheduledAt,
      publishedAt: publishedAt,
      expiresAt: expiresAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: data['createdBy'] as String? ?? data['createdByUid'] as String?,
      updatedBy: data['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> _toFirestore(
    NotificationModel notification, {
    required bool isCreate,
  }) {
    return {
      'id': notification.id,
      'boutiqueId': notification.boutiqueId,
      'branchId': notification.branchId,
      'title': notification.title,
      'body': notification.body,
      'type': notification.type.name,
      'audienceType': notification.audienceType.name,
      'audience': notification.audienceType.name,
      'customerIds': notification.customerIds,
      'targetCustomerUids': notification.customerIds,
      'relatedEntityType': notification.relatedEntityType?.name,
      'relatedEntityId': notification.relatedEntityId,
      'status': notification.status.name,
      'scheduledAt': notification.scheduledAt != null
          ? Timestamp.fromDate(notification.scheduledAt!)
          : null,
      'publishedAt': notification.publishedAt != null
          ? Timestamp.fromDate(notification.publishedAt!)
          : (notification.status == NotificationStatus.published
              ? FieldValue.serverTimestamp()
              : null),
      'expiresAt': notification.expiresAt != null
          ? Timestamp.fromDate(notification.expiresAt!)
          : null,
      'updatedAt': FieldValue.serverTimestamp(),
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
      'createdBy': notification.createdBy,
      'updatedBy': notification.updatedBy,
    };
  }
}
