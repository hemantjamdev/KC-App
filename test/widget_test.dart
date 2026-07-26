import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kc_app/src/app/app.dart';

void main() {
  testWidgets('App startup smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: KcApp()));
    await tester.pump();
    expect(find.byType(KcApp), findsOneWidget);
  });
}
