// This is a basic Flutter widget test for Faith Klinik Ministries app.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:faith_klinik_app/main.dart';
import 'package:faith_klinik_app/providers/app_provider.dart';

void main() {
  testWidgets('App loads and shows welcome screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const FaithKlinikApp(),
      ),
    );

    // Verify that the welcome screen appears
    expect(find.text('Faith Klinik Ministries'), findsAtLeastNWidgets(1));
  });
}
