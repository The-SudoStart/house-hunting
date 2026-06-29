import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_finder/core/routing/app_router.dart';
import 'package:house_finder/core/routing/routes.dart';
import 'package:house_finder/core/theme/app_theme.dart';

void main() {
  setUp(() {
    appRouter.go(AppRoutes.landlordRegistration);
  });

  testWidgets('shows required landlord registration fields', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Landlord Registration'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Full name'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Phone number'), findsOneWidget);
    expect(find.text('Account type'), findsOneWidget);
    expect(find.text('Landlord'), findsOneWidget);
    expect(find.text('Property Agent'), findsOneWidget);
  });

  testWidgets('displays validation errors for invalid input', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your full name.'), findsOneWidget);
    expect(find.text('Enter your phone number.'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Full name'), 'A');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Phone number'),
      '123',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Full name is too short.'), findsOneWidget);
    expect(find.text('Enter a valid phone number.'), findsOneWidget);
  });

  testWidgets('valid input proceeds to phone verification', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full name'),
      'Boris Landlord',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Phone number'),
      '+237 674 123 456',
    );
    await tester.tap(find.text('Property Agent'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Phone Verification'), findsOneWidget);
    expect(find.text('Verify your phone number'), findsOneWidget);
    expect(
      find.text('We will send a verification code to +237674123456.'),
      findsOneWidget,
    );
    expect(find.text('Boris Landlord'), findsOneWidget);
    expect(find.text('Property Agent'), findsOneWidget);
  });
}

Widget _buildApp() {
  return MaterialApp.router(
    theme: AppTheme.lightTheme,
    routerConfig: appRouter,
  );
}
