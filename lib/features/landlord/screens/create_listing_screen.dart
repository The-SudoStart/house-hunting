import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/routes.dart';
import '../../../data/repositories/house_repository.dart';
import '../../../services/house_service.dart';
import '../../home/providers/home_notifier.dart';
import '../models/create_listing_data.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({
    super.key,
    this.houseService,
  });

  final HouseService? houseService;

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _squareFeetController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController(text: 'Cameroon');
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _phoneController = TextEditingController();

  late final HouseService _houseService;
  String _propertyType = 'apartment';
  bool _isSubmitting = false;
  final Set<String> _amenities = {};

  static const _propertyTypes = [
    'apartment',
    'house',
    'studio',
    'hostel',
    'room',
  ];

  static const _availableAmenities = [
    'Parking',
    'Water supply',
    'Security',
    'Generator',
    'Internet',
    'Balcony',
  ];

  @override
  void initState() {
    super.initState();
    _houseService = widget.houseService ?? HouseService();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _squareFeetController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitListing() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate() || _isSubmitting) return;

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() {
      _isSubmitting = true;
    });

    try {
      final listing = await _houseService.createHouse(
        CreateListingData(
          title: _titleController.text.trim(),
          description: _buildDescription(),
          price: double.parse(_priceController.text.trim()),
          bedrooms: _parseInt(_bedroomsController.text),
          bathrooms: _parseDouble(_bathroomsController.text),
          squareFeet: _parseInt(_squareFeetController.text),
          propertyType: _propertyType,
          address: _addressController.text.trim(),
          city: _cityController.text.trim(),
          state: _emptyToNull(_stateController.text),
          zipCode: _emptyToNull(_zipCodeController.text),
          country: _emptyToNull(_countryController.text),
          latitude: _parseDouble(_latitudeController.text),
          longitude: _parseDouble(_longitudeController.text),
          landlordPhone: _normalizePhoneNumber(_phoneController.text),
        ),
      );

      if (!mounted) return;
      try {
        await context.read<HomeNotifier>().refreshHouses();
      } catch (_) {
        // The listing was created; the dashboard can refresh again later.
      }
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Listing #${listing.id} submitted for pending review.',
          ),
        ),
      );
      router.go(AppRoutes.landlordDashboard);
    } on HouseRepositoryException catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('We could not submit this listing. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String? _buildDescription() {
    final description = _descriptionController.text.trim();
    if (_amenities.isEmpty) return _emptyToNull(description);

    final amenityText = 'Amenities: ${_amenities.join(', ')}.';
    if (description.isEmpty) return amenityText;
    return '$description\n\n$amenityText';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go(AppRoutes.landlordDashboard),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
        title: const Text('Create Listing'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'New property listing',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Complete the required fields to submit for review.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _FormSection(
                        title: 'Property Information',
                        icon: Icons.home_work_outlined,
                        children: [
                          TextFormField(
                            controller: _titleController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Listing title',
                              prefixIcon: Icon(Icons.title),
                            ),
                            validator: _validateRequired,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _propertyType,
                            decoration: const InputDecoration(
                              labelText: 'Property type',
                              prefixIcon: Icon(Icons.apartment),
                            ),
                            items: _propertyTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(_capitalize(type)),
                                  ),
                                )
                                .toList(growable: false),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _propertyType = value;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descriptionController,
                            minLines: 3,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              alignLabelWithHint: true,
                              prefixIcon: Icon(Icons.notes_outlined),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _ResponsiveFields(
                            children: [
                              TextFormField(
                                controller: _bedroomsController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Bedrooms',
                                  prefixIcon: Icon(Icons.bed_outlined),
                                ),
                                validator: _validateOptionalPositiveInt,
                              ),
                              TextFormField(
                                controller: _bathroomsController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]'),
                                  ),
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Bathrooms',
                                  prefixIcon: Icon(Icons.bathtub_outlined),
                                ),
                                validator: _validateOptionalPositiveDouble,
                              ),
                              TextFormField(
                                controller: _squareFeetController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Area in m2',
                                  prefixIcon: Icon(Icons.square_foot),
                                ),
                                validator: _validateOptionalPositiveInt,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _FormSection(
                        title: 'Pricing',
                        icon: Icons.payments_outlined,
                        children: [
                          TextFormField(
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Monthly rent',
                              prefixIcon: Icon(Icons.payments_outlined),
                              suffixText: 'FCFA',
                            ),
                            validator: _validateRequiredPositiveDouble,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _FormSection(
                        title: 'Location',
                        icon: Icons.location_on_outlined,
                        children: [
                          TextFormField(
                            controller: _addressController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Address',
                              prefixIcon: Icon(Icons.place_outlined),
                            ),
                            validator: _validateRequired,
                          ),
                          const SizedBox(height: 12),
                          _ResponsiveFields(
                            children: [
                              TextFormField(
                                controller: _cityController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'City',
                                  prefixIcon: Icon(Icons.location_city),
                                ),
                                validator: _validateRequired,
                              ),
                              TextFormField(
                                controller: _stateController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'State / region',
                                  prefixIcon: Icon(Icons.map_outlined),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _ResponsiveFields(
                            children: [
                              TextFormField(
                                controller: _zipCodeController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Postal code',
                                  prefixIcon: Icon(Icons.local_post_office),
                                ),
                              ),
                              TextFormField(
                                controller: _countryController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Country',
                                  prefixIcon: Icon(Icons.public_outlined),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _ResponsiveFields(
                            children: [
                              TextFormField(
                                controller: _latitudeController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  signed: true,
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[-0-9.]'),
                                  ),
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Latitude',
                                  prefixIcon: Icon(Icons.my_location),
                                ),
                                validator: _validateOptionalDouble,
                              ),
                              TextFormField(
                                controller: _longitudeController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  signed: true,
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[-0-9.]'),
                                  ),
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Longitude',
                                  prefixIcon: Icon(Icons.explore_outlined),
                                ),
                                validator: _validateOptionalDouble,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _FormSection(
                        title: 'Amenities',
                        icon: Icons.checklist_outlined,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availableAmenities.map((amenity) {
                              final selected = _amenities.contains(amenity);
                              return FilterChip(
                                label: Text(amenity),
                                selected: selected,
                                onSelected: (value) {
                                  setState(() {
                                    if (value) {
                                      _amenities.add(amenity);
                                    } else {
                                      _amenities.remove(amenity);
                                    }
                                  });
                                },
                              );
                            }).toList(growable: false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _FormSection(
                        title: 'Contact',
                        icon: Icons.phone_outlined,
                        children: [
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9+\-\s()]'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Landlord phone',
                              hintText: '+237 674 123 456',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                            validator: _validatePhoneNumber,
                            onFieldSubmitted: (_) => _submitListing(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _isSubmitting ? null : _submitListing,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.task_alt_outlined),
                        label: Text(
                          _isSubmitting
                              ? 'Submitting listing'
                              : 'Submit for review',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateRequired(String? value) {
    if ((value ?? '').trim().isEmpty) return 'This field is required.';
    return null;
  }

  String? _validateRequiredPositiveDouble(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) return 'This field is required.';
    final number = double.tryParse(trimmed);
    if (number == null || number <= 0) {
      return 'Enter a number greater than zero.';
    }
    return null;
  }

  String? _validateOptionalPositiveInt(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) return null;
    final number = int.tryParse(trimmed);
    if (number == null || number <= 0) {
      return 'Enter a whole number greater than zero.';
    }
    return null;
  }

  String? _validateOptionalPositiveDouble(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) return null;
    final number = double.tryParse(trimmed);
    if (number == null || number <= 0) {
      return 'Enter a number greater than zero.';
    }
    return null;
  }

  String? _validateOptionalDouble(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) return null;
    if (double.tryParse(trimmed) == null) return 'Enter a valid number.';
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    final phone = _normalizePhoneNumber(value ?? '');
    if (phone.isEmpty) return 'This field is required.';
    if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(phone)) {
      return 'Enter a valid phone number.';
    }
    return null;
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  int? _parseInt(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : int.parse(trimmed);
  }

  double? _parseDouble(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : double.parse(trimmed);
  }

  String _normalizePhoneNumber(String value) {
    return value.replaceAll(RegExp(r'[\s\-()]'), '').trim();
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ResponsiveFields extends StatelessWidget {
  const _ResponsiveFields({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 640) {
          return Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                children[i],
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(child: children[i]),
            ],
          ],
        );
      },
    );
  }
}
