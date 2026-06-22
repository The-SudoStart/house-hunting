import 'package:flutter_test/flutter_test.dart';
import 'package:house_finder/main.dart';

void main() {
  testWidgets('App launches and shows welcome text', (WidgetTester tester) async {
    await tester.pumpWidget(const HouseFinderApp());
    await tester.pumpAndSettle();

    expect(find.text('House Finder'), findsOneWidget);
    expect(find.text('Welcome to House Finder'), findsOneWidget);
  });

  testWidgets('Navigation to House Details works', (WidgetTester tester) async {
    await tester.pumpWidget(const HouseFinderApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome to House Finder'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('House Details'), findsOneWidget);
    expect(find.text('House #1'), findsOneWidget);
  });
}
