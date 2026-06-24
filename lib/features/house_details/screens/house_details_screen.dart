import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/house.dart';
import '../../home/providers/home_notifier.dart';

class HouseDetailsScreen extends StatelessWidget {
  const HouseDetailsScreen({
    super.key,
    required this.houseId,
    this.house,
  });

  final String houseId;
  final House? house;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    House? currentHouse = house;
    if (currentHouse == null) {
      final notifier = context.read<HomeNotifier>();
      try {
        final id = int.parse(houseId);
        currentHouse = notifier.allHouses.firstWhere((h) => h.id == id);
      } catch (_) {}
    }

    if (currentHouse == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('House Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home_work_outlined,
                size: 64,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'House not found',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'This listing may have been removed.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Text(
                    currentHouse.title,
                    style: theme.textTheme.titleMedium,
                  ),
                  pinned: true,
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ImageSection(house: currentHouse),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _TitlePriceSection(house: currentHouse),
                            const SizedBox(height: 12),
                            _AddressSection(house: currentHouse),
                            const SizedBox(height: 16),
                            _PropertyInfoSection(house: currentHouse),
                            if (currentHouse.description != null &&
                                currentHouse.description!.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              _DescriptionSection(house: currentHouse),
                            ],
                            const SizedBox(height: 24),
                            _ContactSection(house: currentHouse),
                            const SizedBox(height: 24),
                            _LocationSection(house: currentHouse),
                            const SizedBox(height: 32),
                          ],
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
    );
  }
}

class _ImageSection extends StatelessWidget {
  const _ImageSection({required this.house});

  final House house;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (house.imageUrl != null && house.imageUrl!.isNotEmpty) {
      return Image.network(
        house.imageUrl!,
        width: double.infinity,
        height: 280,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(colorScheme);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder(colorScheme, showLoading: true);
        },
      );
    }

    return _buildPlaceholder(colorScheme);
  }

  Widget _buildPlaceholder(ColorScheme colorScheme, {bool showLoading = false}) {
    return Container(
      width: double.infinity,
      height: 280,
      color: colorScheme.surfaceContainerHighest,
      child: showLoading
          ? Center(
              child: CircularProgressIndicator(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            )
          : Icon(
              Icons.home,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
    );
  }
}

class _TitlePriceSection extends StatelessWidget {
  const _TitlePriceSection({required this.house});

  final House house;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            house.title,
            style: theme.textTheme.headlineSmall,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${_formatPrice(house.price)} FCFA/mo',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        );
  }
}

class _AddressSection extends StatelessWidget {
  const _AddressSection({required this.house});

  final House house;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final parts = <String>[
      house.address,
      house.city,
      if (house.state != null) house.state!,
      if (house.zipCode != null) house.zipCode!,
      if (house.country != null) house.country!,
    ];

    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: 18,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            parts.join(', '),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _PropertyInfoSection extends StatelessWidget {
  const _PropertyInfoSection({required this.house});

  final House house;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final items = <_InfoItem>[];

    if (house.bedrooms != null) {
      items.add(_InfoItem(
        icon: Icons.bed_outlined,
        label: '${house.bedrooms}',
        subtitle: house.bedrooms == 1 ? 'Bedroom' : 'Bedrooms',
      ));
    }

    if (house.bathrooms != null) {
      items.add(_InfoItem(
        icon: Icons.bathroom_outlined,
        label: house.bathrooms!.toStringAsFixed(1),
        subtitle: house.bathrooms! == 1 ? 'Bathroom' : 'Bathrooms',
      ));
    }

    if (house.squareFeet != null) {
      items.add(_InfoItem(
        icon: Icons.square_foot,
        label: '${house.squareFeet}',
        subtitle: 'm²',
      ));
    }

    if (house.propertyType != null) {
      items.add(_InfoItem(
        icon: Icons.home_outlined,
        label: _capitalize(house.propertyType!),
        subtitle: 'Type',
      ));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map((item) => _buildInfoCard(context, item, theme, colorScheme))
          .toList(),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    _InfoItem item,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                item.subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.house});

  final House house;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          house.description!,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.house});

  final House house;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Landlord',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                child: const Icon(Icons.person, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Landlord',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          house.landlordPhone,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  // Phone call intent could be launched here
                },
                icon: const Icon(Icons.phone, size: 18),
                label: const Text('Call'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationSection extends StatelessWidget {
  const _LocationSection({required this.house});

  final House house;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasGeo = house.latitude != null && house.longitude != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${house.address}, ${house.city}${house.state != null ? ', ${house.state}' : ''}${house.zipCode != null ? ' ${house.zipCode}' : ''}${house.country != null ? ', ${house.country}' : ''}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              if (hasGeo) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.my_location,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${house.latitude!.toStringAsFixed(4)}, ${house.longitude!.toStringAsFixed(4)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String subtitle;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.subtitle,
  });
}