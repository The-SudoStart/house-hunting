import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_finder/main.dart';

void main() {
  testWidgets('App launches and shows header and search field', (WidgetTester tester) async {
    await tester.pumpWidget(const HouseFinderApp());
    await tester.pump(); // First frame

    expect(find.text('House Finder'), findsOneWidget);
    expect(find.text('Find your perfect home'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Advance past the mock loading delay
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    // Houses should be visible after loading
    expect(find.byType(Card), findsWidgets);
  });

  testWidgets('Search filters the house list', (WidgetTester tester) async {
    await tester.pumpWidget(const HouseFinderApp());
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    // Verify all houses are shown initially
    expect(find.byType(Card), findsWidgets);

    // Enter a search query that matches only some listings
    await tester.enterText(find.byType(TextField), 'Yaoundé');
    await tester.pumpAndSettle();

    // Filtered results should still show cards (Yaoundé houses)
    expect(find.byType(Card), findsWidgets);

    // Enter a query that matches nothing
    await tester.enterText(find.byType(TextField), 'xyzabc123');
    await tester.pumpAndSettle();

    // Empty state should be shown
    expect(find.text('No houses found'), findsOneWidget);
    expect(find.text('Try adjusting your search criteria'), findsOneWidget);
  });

  testWidgets('Navigation to House Details works', (WidgetTester tester) async {
    await tester.pumpWidget(const HouseFinderApp());
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    // Tap the first house card
    await tester.tap(find.byType(Card).first);
    await tester.pumpAndSettle();

    expect(find.text('House Details'), findsOneWidget);
    expect(find.text('House #1'), findsOneWidget);
  });
}
