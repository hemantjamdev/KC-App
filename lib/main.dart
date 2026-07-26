import 'package:flutter/widgets.dart';
import 'package:kc_app/src/app/app.dart';
import 'package:kc_app/src/bootstrap/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await bootstrap(() => const KcApp());
}
