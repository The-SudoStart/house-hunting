import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:house_finder/core/routing/routes.dart';
import 'package:house_finder/core/theme/app_theme.dart';
import 'package:house_finder/features/auth/models/landlord_profile.dart';
import 'package:house_finder/features/auth/models/landlord_registration_data.dart';
import 'package:house_finder/features/auth/screens/landlord_registration_screen.dart';
import 'package:house_finder/features/auth/services/landlord_profile_service.dart';

void main() {
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

    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your full name.'), findsOneWidget);
    expect(find.text('Enter your phone number.'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Full name'), 'A');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Phone number'),
      '123',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Full name is too short.'), findsOneWidget);
    expect(find.text('Enter a valid phone number.'), findsOneWidget);
  });

  testWidgets('valid input creates profile and opens dashboard', (
    tester,
  ) async {
    final profileService = _FakeLandlordProfileService();
    await tester.pumpWidget(_buildApp(profileService: profileService));
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

    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(profileService.createdProfileData?.fullName, 'Boris Landlord');
    expect(profileService.createdProfileData?.phoneNumber, '+237674123456');
    expect(
      profileService.createdProfileData?.accountType,
      LandlordAccountType.propertyAgent,
    );
    expect(find.text('Landlord Dashboard'), findsOneWidget);
  });
}

Widget _buildApp({LandlordProfileService? profileService}) {
  final router = GoRouter(
    initialLocation: AppRoutes.landlordRegistration,
    routes: [
      GoRoute(
        path: AppRoutes.landlordRegistration,
        builder: (context, state) {
          return LandlordRegistrationScreen(profileService: profileService);
        },
      ),
      GoRoute(
        path: AppRoutes.landlordDashboard,
        builder: (context, state) {
          return const Scaffold(
            body: Center(child: Text('Landlord Dashboard')),
          );
        },
      ),
    ],
  );

  return MaterialApp.router(
    theme: AppTheme.lightTheme,
    routerConfig: router,
  );
}

class _FakeLandlordProfileService extends LandlordProfileService {
  LandlordRegistrationData? createdProfileData;

  @override
  Future<LandlordProfile> createVerifiedProfile(
    LandlordRegistrationData registrationData,
  ) async {
    createdProfileData = registrationData;
    return LandlordProfile(
      id: 1,
      fullName: registrationData.fullName,
      verifiedPhoneNumber: registrationData.phoneNumber,
      accountType: registrationData.accountType,
    );
  }
}
