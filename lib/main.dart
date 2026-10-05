import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:kc_app/src/app/app.dart';
import 'package:kc_app/src/bootstrap/bootstrap.dart';
import 'package:kc_app/src/features/notification/data/services/firebase_messaging_service.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e, stack) {
    debugPrint('Firebase initialization warning: $e\n$stack');
  }

  await bootstrap(() => const KcApp());
}
