import 'package:flutter/material.dart';

import '../../../models/house.dart';

class HouseListItem extends StatelessWidget {
  final House house;
  final double? distanceKm;
  final VoidCallback? onTap;

  const HouseListItem({
    super.key,
    required this.house,
    this.distanceKm,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RepaintBoundary(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  _buildImage(colorScheme),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: _StatusBadge(house: house),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            house.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_formatPrice(house.price)} FCFA',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _locationLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _MetaChip(icon: Icons.tag, label: '#${house.id}'),
                        if (house.createdAt != null)
                          _MetaChip(
                            icon: Icons.calendar_today,
                            label: 'Listed ${_formatDate(house.createdAt!)}',
                          ),
                        if (house.updatedAt != null)
                          _MetaChip(
                            icon: Icons.update,
                            label: 'Updated ${_formatDate(house.updatedAt!)}',
                          ),
                      ],
                    ),
                    if (distanceKm != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.near_me,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDistance(distanceKm!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (house.propertyType != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _capitalize(house.propertyType!),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                    if (house.bedrooms != null ||
                        house.bathrooms != null ||
                        house.squareFeet != null) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (house.bedrooms != null)
                            _IconMetric(
                              icon: Icons.bed,
                              label: '${house.bedrooms} Beds',
                            ),
                          if (house.bathrooms != null)
                            _IconMetric(
                              icon: Icons.bathroom,
                              label:
                                  '${house.bathrooms?.toStringAsFixed(1) ?? '0.0'} Baths',
                            ),
                          if (house.squareFeet != null)
                            _IconMetric(
                              icon: Icons.square_foot,
                              label: '${house.squareFeet} m²',
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _locationLabel {
    final parts = [
      if (house.neighborhood != null && house.neighborhood!.isNotEmpty)
        house.neighborhood!,
      house.city,
      house.address,
    ];

    return parts.join(', ');
  }

  Widget _buildImage(ColorScheme colorScheme) {
    if (house.imageUrl != null && house.imageUrl!.isNotEmpty) {
      return Image.network(
        house.imageUrl!,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        cacheWidth: 900,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(colorScheme);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder(colorScheme);
        },
      );
    }
    return _buildPlaceholder(colorScheme);
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      height: 180,
      width: double.infinity,
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.home,
        size: 48,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  String _formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m away';
    }

    return '${distanceKm.toStringAsFixed(1)} km away';
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.year}-${_twoDigits(local.month)}-${_twoDigits(local.day)}';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

class _StatusBadge extends StatelessWidget {
  final House house;

  const _StatusBadge({required this.house});

  @override
  Widget build(BuildContext context) {
    final status = house.availabilityStatus.toLowerCase();
    final available = status == 'available';
    final colorScheme = Theme.of(context).colorScheme;
    final background =
        available ? colorScheme.primaryContainer : colorScheme.errorContainer;
    final foreground = available
        ? colorScheme.onPrimaryContainer
        : colorScheme.onErrorContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        available ? 'Available' : 'Rented',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _IconMetric extends StatelessWidget {
  final IconData icon;
  final String label;

  const _IconMetric({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
