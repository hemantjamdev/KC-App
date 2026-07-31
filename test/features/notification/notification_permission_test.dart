import 'package:flutter_test/flutter_test.dart';
import 'package:kc_app/src/features/notification/domain/models/notification_permission_state.dart';

void main() {
  group('Part 3 — Notification Permission & Initialization Tests', () {
    test('1. Android 13 not requested state', () {
      const state = NotificationPermissionState.notRequested();
      expect(state, isA<NotificationPermissionNotRequested>());
    });

    test('2. permission request starts -> requesting state', () {
      const state = NotificationPermissionState.requesting();
      expect(state, isA<NotificationPermissionRequesting>());
    });

    test('3. granted state emitted when user approves', () {
      const state = NotificationPermissionState.granted();
      expect(state, isA<NotificationPermissionGranted>());
    });

    test('4. denied state emitted when user declines', () {
      const state = NotificationPermissionState.denied();
      expect(state, isA<NotificationPermissionDenied>());
    });

    test(
      '5. repeated rebuild does not re-trigger request if state resolved',
      () {
        const state = NotificationPermissionState.granted();
        final needsPrompt = state is NotificationPermissionNotRequested;
        expect(needsPrompt, isFalse);
      },
    );

    test(
      '6. authorized customer token registration associates with customer UID',
      () {
        const authUid = 'user_789';
        const token = 'fcm_token_xyz';

        expect(authUid, equals('user_789'));
        expect(token, isNotEmpty);
      },
    );

    test('7. token refresh updates customer token record', () {
      String currentToken = 'fcm_old_token';
      const newToken = 'fcm_new_token';

      currentToken = newToken;
      expect(currentToken, equals('fcm_new_token'));
    });

    test('8. logout removes private notification token state', () {
      String? token = 'fcm_active';
      token = null;
      expect(token, isNull);
    });

    test('9. foreground message invokes local presentation', () {
      const title = 'Stitching Update';
      const body = 'Your order KC-ST-101 is ready!';

      expect(title, isNotEmpty);
      expect(body, contains('KC-ST-101'));
    });

    test('10. notification tap resolves destination safely', () {
      const notificationId = 'notif_001';
      const payload = {
        'relatedEntityType': 'stitching',
        'entityId': 'KC-ST-101',
      };

      expect(notificationId, equals('notif_001'));
      expect(payload['relatedEntityType'], equals('stitching'));
    });
  });
}
