import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/routes.dart';
import '../models/landlord_registration_data.dart';
import '../services/landlord_profile_service.dart';

class LandlordRegistrationScreen extends StatefulWidget {
  const LandlordRegistrationScreen({
    super.key,
    this.profileService,
  });

  final LandlordProfileService? profileService;

  @override
  State<LandlordRegistrationScreen> createState() =>
      _LandlordRegistrationScreenState();
}

class _LandlordRegistrationScreenState
    extends State<LandlordRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  late final LandlordProfileService _profileService;
  LandlordAccountType _accountType = LandlordAccountType.landlord;
  bool _isCreatingProfile = false;

  @override
  void initState() {
    super.initState();
    _profileService = widget.profileService ?? LandlordProfileService();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate() || _isCreatingProfile) return;

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() {
      _isCreatingProfile = true;
    });

    try {
      await _profileService.createVerifiedProfile(
        LandlordRegistrationData(
          fullName: _fullNameController.text.trim(),
          phoneNumber: _normalizePhoneNumber(_phoneController.text),
          accountType: _accountType,
        ),
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Landlord profile created.')),
      );
      router.go(AppRoutes.landlordDashboard);
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('We could not create your profile. Please try again.'),
        ),
      );
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go(AppRoutes.home),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
        title: const Text('Landlord Registration'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create your listing account',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your details to create your listing account.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _fullNameController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [AutofillHints.name],
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: _validateFullName,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9+\-\s()]'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Phone number',
                            hintText: '+237 674 123 456',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          validator: _validatePhoneNumber,
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Account type',
                          style: theme.textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<LandlordAccountType>(
                          segments: const [
                            ButtonSegment(
                              value: LandlordAccountType.landlord,
                              icon: Icon(Icons.home_work_outlined),
                              label: Text('Landlord'),
                            ),
                            ButtonSegment(
                              value: LandlordAccountType.propertyAgent,
                              icon: Icon(Icons.badge_outlined),
                              label: Text('Property Agent'),
                            ),
                          ],
                          selected: {_accountType},
                          onSelectionChanged: (selection) {
                            setState(() {
                              _accountType = selection.first;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _isCreatingProfile ? null : _submit,
                          icon: _isCreatingProfile
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.person_add_alt_1_outlined),
                          label: Text(
                            _isCreatingProfile
                                ? 'Creating profile'
                                : 'Create account',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validateFullName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Enter your full name.';
    if (name.length < 3) return 'Full name is too short.';
    if (!RegExp(r"^[A-Za-zÀ-ÿ' -]+$").hasMatch(name)) {
      return 'Use letters, spaces, apostrophes, or hyphens only.';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    final phone = _normalizePhoneNumber(value ?? '');
    if (phone.isEmpty) return 'Enter your phone number.';
    if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(phone)) {
      return 'Enter a valid phone number.';
    }
    return null;
  }

  String _normalizePhoneNumber(String value) {
    return value.replaceAll(RegExp(r'[\s\-()]'), '').trim();
  }
}
