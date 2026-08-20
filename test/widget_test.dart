import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leximpactai/app.dart';

void main() {
  testWidgets('LeximpactAI App loads home screen title', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('LEXIMPACT AI'), findsOneWidget);
  });
}
