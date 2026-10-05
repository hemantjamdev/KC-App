import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kc_app/src/core/errors/failure_mapper.dart';
import 'package:kc_app/src/core/providers/firebase_providers.dart';
import 'package:kc_app/src/features/auth/application/providers/auth_providers.dart';
import 'package:kc_app/src/features/notification/data/repositories/notification_firestore_repository.dart';
import 'package:kc_app/src/features/notification/data/services/firebase_messaging_service.dart';
import 'package:kc_app/src/features/notification/domain/models/notification_model.dart';
import 'package:kc_app/src/features/notification/domain/models/notification_permission_state.dart';
import 'package:kc_app/src/features/notification/domain/models/notification_messaging_state.dart';

// ─────────────────────────────────────────────
// Repository & Service providers
// ─────────────────────────────────────────────

final notificationRepositoryProvider =
    Provider<NotificationFirestoreRepository>((ref) {
      return NotificationFirestoreRepository(
        firestore: ref.watch(firebaseFirestoreProvider),
      );
    });

final firebaseMessagingServiceProvider = Provider<FirebaseMessagingService>((
  ref,
) {
  return FirebaseMessagingService();
});

// ─────────────────────────────────────────────
// Notification Permission Notifier
// ─────────────────────────────────────────────

final notificationPermissionProvider =
    NotifierProvider<
      NotificationPermissionNotifier,
      NotificationPermissionState
    >(NotificationPermissionNotifier.new);

class NotificationPermissionNotifier
    extends Notifier<NotificationPermissionState> {
  @override
  NotificationPermissionState build() {
    Future.microtask(() => checkPermissionStatus());
    return const NotificationPermissionState.unknown();
  }

  Future<void> checkPermissionStatus() async {
    try {
      final status = await Permission.notification.status;
      if (status.isGranted) {
        state = const NotificationPermissionState.granted();
      } else if (status.isPermanentlyDenied) {
        state = const NotificationPermissionState.permanentlyDenied();
      } else {
        state = const NotificationPermissionState.notRequested();
      }
    } catch (e, st) {
      state = NotificationPermissionState.failure(FailureMapper.map(e, st));
    }
  }

  Future<void> requestPermission({String? customerUid}) async {
    if (state is NotificationPermissionRequesting) return;
    state = const NotificationPermissionState.requesting();

    try {
      final service = ref.read(firebaseMessagingServiceProvider);
      final settings = await service.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        state = const NotificationPermissionState.granted();
        if (customerUid != null && customerUid.isNotEmpty) {
          await ref.read(notificationMessagingProvider.notifier).initializeForUser(
            uid: customerUid,
          );
        }
      } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
        state = const NotificationPermissionState.denied();
      } else {
        state = const NotificationPermissionState.notRequested();
      }
    } catch (e, st) {
      state = NotificationPermissionState.failure(FailureMapper.map(e, st));
    }
  }
}

// ─────────────────────────────────────────────
// Notification Messaging Coordinator Notifier
// ─────────────────────────────────────────────

final notificationMessagingProvider = NotifierProvider<
    NotificationMessagingNotifier,
    NotificationMessagingState
>(NotificationMessagingNotifier.new);

class NotificationMessagingNotifier
    extends Notifier<NotificationMessagingState> {
  @override
  NotificationMessagingState build() {
    return const NotificationMessagingState.idle();
  }

  Future<void> initializeForUser({required String uid}) async {
    if (uid.isEmpty) return;
    state = const NotificationMessagingState.initializing();

    try {
      final service = ref.read(firebaseMessagingServiceProvider);
      await service.initialize(
        customerId: uid,
        firebaseUid: uid,
      );
      final token = service.currentToken ?? '';
      state = NotificationMessagingState.ready(
        tokenRegistered: token.isNotEmpty,
        token: token,
      );
    } catch (e, st) {
      state = NotificationMessagingState.failure(FailureMapper.map(e, st));
    }
  }
}

// ─────────────────────────────────────────────
// Customer Notification list — live stream
// ─────────────────────────────────────────────

final notificationListProvider = StreamProvider<List<NotificationModel>>((ref) {
  final user = ref.watch(currentCustomerUserProvider);
  return ref
      .watch(notificationRepositoryProvider)
      .watchCustomerNotifications(customerUid: user?.uid);
});

final customerReadNotificationIdsProvider = StreamProvider<Set<String>>((ref) {
  final user = ref.watch(currentCustomerUserProvider);
  if (user == null || user.uid.isEmpty) return Stream.value(<String>{});
  return ref.watch(notificationRepositoryProvider).watchReadNotificationIds(user.uid);
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationListProvider).valueOrNull ?? [];
  final readIds = ref.watch(customerReadNotificationIdsProvider).valueOrNull ?? {};
  return list.where((n) => !readIds.contains(n.id)).length;
});
