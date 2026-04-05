// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:basira/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BasiraApp(),
      ),
    );

    expect(find.text('Basira'), findsOneWidget);
  });
}
