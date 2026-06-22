import 'package:flutter_test/flutter_test.dart';
import 'package:house_finder/main.dart';

void main() {
  testWidgets('App launches and shows welcome text', (WidgetTester tester) async {
    await tester.pumpWidget(const HouseFinderApp());

    expect(find.text('House Finder'), findsOneWidget);
    expect(find.text('Welcome to House Finder'), findsOneWidget);
  });
}
