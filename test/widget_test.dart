import 'package:flutter_test/flutter_test.dart';
import 'package:caros2/main.dart';

void main() {
  testWidgets('App abre sem erro', (WidgetTester tester) async {
    await tester.pumpWidget(const CarOs2App());
    expect(find.text('Home'), findsOneWidget);
  });
}
