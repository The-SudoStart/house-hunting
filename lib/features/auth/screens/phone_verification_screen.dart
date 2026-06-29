import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/routes.dart';
import '../models/landlord_profile.dart';
import '../models/landlord_registration_data.dart';
import '../services/landlord_profile_service.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({
    super.key,
    required this.registrationData,
    this.profileService,
  });

  final LandlordRegistrationData? registrationData;
  final LandlordProfileService? profileService;

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  late final LandlordProfileService _profileService;

  LandlordProfile? _profile;
  String? _errorMessage;
  bool _isCreatingProfile = false;

  @override
  void initState() {
    super.initState();
    _profileService = widget.profileService ?? LandlordProfileService();
  }

  Future<void> _verifyAndCreateProfile() async {
    final data = widget.registrationData;
    if (data == null || _isCreatingProfile) return;

    setState(() {
      _isCreatingProfile = true;
      _errorMessage = null;
    });

    try {
      final profile = await _profileService.createVerifiedProfile(data);
      if (!mounted) return;
      setState(() {
        _profile = profile;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'We could not create your profile. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingProfile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final data = widget.registrationData;

    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Phone Verification')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sms_failed_outlined,
                  size: 56,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Registration details are missing',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.landlordRegistration),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Start registration'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go(AppRoutes.landlordRegistration),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
        title: const Text('Phone Verification'),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.mark_chat_unread_outlined,
                    size: 64,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Verify your phone number',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We will send a verification code to ${data.phoneNumber}.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(_profile?.fullName ?? data.fullName),
                    subtitle: Text(
                      _profile == null
                          ? data.accountType.label
                          : '${_profile!.accountType.label} - ${_profile!.verifiedPhoneNumber}',
                    ),
                  ),
                  if (_profile != null) ...[
                    const SizedBox(height: 12),
                    Icon(
                      Icons.verified_outlined,
                      size: 40,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Profile created',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _isCreatingProfile
                          ? null
                          : _verifyAndCreateProfile,
                      icon: _isCreatingProfile
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.verified_user_outlined),
                      label: Text(
                        _isCreatingProfile
                            ? 'Creating profile'
                            : 'Verify and create profile',
                      ),
                    ),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
