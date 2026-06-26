import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/routing/routes.dart';
import '../../../models/house.dart';
import '../../home/providers/home_notifier.dart';
import '../../home/providers/home_state.dart';

class HouseDetailsScreen extends StatefulWidget {
  const HouseDetailsScreen({
    super.key,
    required this.houseId,
  });

  final String houseId;

  @override
  State<HouseDetailsScreen> createState() => _HouseDetailsScreenState();
}

class _HouseDetailsScreenState extends State<HouseDetailsScreen> {
  final PageController _pageController = PageController();
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = context.read<HomeNotifier>();
      if (notifier.allHouses.isEmpty && notifier.state is! HomeLoading) {
        notifier.loadHouses();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final houseId = int.tryParse(widget.houseId);

    return Scaffold(
      body: SafeArea(
        child: Consumer<HomeNotifier>(
          builder: (context, notifier, _) {
            final house = houseId == null ? null : notifier.houseById(houseId);

            if (house == null) {
              return switch (notifier.state) {
                HomeInitial() || HomeLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                _ => _buildNotFound(),
              };
            }

            return _buildDetails(context, notifier, house);
          },
        ),
      ),
    );
  }

  Widget _buildDetails(
    BuildContext context,
    HomeNotifier notifier,
    House house,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final images = house.imageUrls.isNotEmpty
        ? house.imageUrls
        : [
            if (house.imageUrl != null && house.imageUrl!.isNotEmpty)
              house.imageUrl!,
          ];

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 320,
          leading: IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
            icon: const Icon(Icons.arrow_back),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: _ImageGallery(
              images: images,
              pageController: _pageController,
              selectedIndex: _selectedImageIndex,
              onChanged: (index) {
                setState(() {
                  _selectedImageIndex = index;
                });
              },
              onOpenFullscreen: () => _openFullscreenGallery(images),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(house.title, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${_formatPrice(house.price)} FCFA',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (notifier.distanceForHouse(house) != null)
                          _InfoChip(
                            icon: Icons.near_me,
                            label: _formatDistance(
                              notifier.distanceForHouse(house)!,
                            ),
                          ),
                        _InfoChip(
                          icon: Icons.fact_check,
                          label: _statusLabel(house),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _Section(
                      title: 'Description',
                      child: Text(
                        house.description?.trim().isNotEmpty == true
                            ? house.description!
                            : 'No description provided.',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    _Section(
                      title: 'Property information',
                      child: _PropertyInfoGrid(house: house),
                    ),
                    _Section(
                      title: 'Contact information',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                size: 20,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              SelectableText(
                                house.landlordPhone,
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () => _callLandlord(house),
                            icon: const Icon(Icons.call),
                            label: const Text('Call'),
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
      ],
    );
  }

  Widget _buildNotFound() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.home_work_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text('House not found', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.go(AppRoutes.home),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFullscreenGallery(List<String> images) async {
    if (images.isEmpty) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullscreenGallery(
          images: images,
          initialIndex: _selectedImageIndex,
        ),
      ),
    );
  }

  Future<void> _callLandlord(House house) async {
    final phone = house.landlordPhone.trim();
    if (!_isValidPhoneNumber(phone)) {
      _showMessage('This phone number is not valid.');
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);
    if (!await canLaunchUrl(uri)) {
      _showMessage('No phone dialer is available on this device.');
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      _showMessage('Could not open the phone dialer.');
    }
  }

  bool _isValidPhoneNumber(String value) {
    return RegExp(r'^\+?[0-9][0-9\s().-]{5,}$').hasMatch(value);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  String _formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m away';
    }

    return '${distanceKm.toStringAsFixed(1)} km away';
  }

  String _statusLabel(House house) {
    final status = house.availabilityStatus.toLowerCase();
    return status == 'available' ? 'Available' : 'Rented';
  }
}

class _ImageGallery extends StatelessWidget {
  final List<String> images;
  final PageController pageController;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final VoidCallback onOpenFullscreen;

  const _ImageGallery({
    required this.images,
    required this.pageController,
    required this.selectedIndex,
    required this.onChanged,
    required this.onOpenFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (images.isEmpty) {
      return Container(
        color: colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.home,
          size: 72,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: pageController,
          onPageChanged: onChanged,
          itemCount: images.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: onOpenFullscreen,
              child: Image.network(
                images[index],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.broken_image,
                      size: 56,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: IconButton.filledTonal(
            onPressed: onOpenFullscreen,
            icon: const Icon(Icons.fullscreen),
            tooltip: 'Open full screen',
          ),
        ),
        if (images.length > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 18,
            child: _ImageIndicator(
              count: images.length,
              selectedIndex: selectedIndex,
            ),
          ),
      ],
    );
  }
}

class _ImageIndicator extends StatelessWidget {
  final int count;
  final int selectedIndex;

  const _ImageIndicator({
    required this.count,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final selected = index == selectedIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: selected ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: selected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _FullscreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullscreenGallery({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
  late final PageController _controller;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_selectedIndex + 1} / ${widget.images.length}'),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: Center(
                  child: Image.network(
                    widget.images[index],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image,
                        color: Colors.white70,
                        size: 64,
                      );
                    },
                  ),
                ),
              );
            },
          ),
          if (widget.images.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: _ImageIndicator(
                count: widget.images.length,
                selectedIndex: _selectedIndex,
              ),
            ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _PropertyInfoGrid extends StatelessWidget {
  final House house;

  const _PropertyInfoGrid({required this.house});

  @override
  Widget build(BuildContext context) {
    final items = [
      _InfoItem(Icons.tag, 'Listing ID', '#${house.id}'),
      _InfoItem(Icons.fact_check, 'Status', _statusLabel(house)),
      _InfoItem(Icons.location_on, 'Address', _formatAddress(house)),
      if (house.neighborhood != null)
        _InfoItem(Icons.map, 'Neighborhood', house.neighborhood!),
      if (house.propertyType != null)
        _InfoItem(Icons.apartment, 'Type', _capitalize(house.propertyType!)),
      if (house.bedrooms != null)
        _InfoItem(Icons.bed, 'Bedrooms', '${house.bedrooms}'),
      if (house.bathrooms != null)
        _InfoItem(
          Icons.bathroom,
          'Bathrooms',
          house.bathrooms!.toStringAsFixed(1),
        ),
      if (house.squareFeet != null)
        _InfoItem(Icons.square_foot, 'Area', '${house.squareFeet} m²'),
      if (house.country != null)
        _InfoItem(Icons.public, 'Country', house.country!),
      if (house.latitude != null && house.longitude != null)
        _InfoItem(
          Icons.explore,
          'Coordinates',
          '${house.latitude!.toStringAsFixed(4)}, '
              '${house.longitude!.toStringAsFixed(4)}',
        ),
      if (house.createdAt != null)
        _InfoItem(Icons.calendar_today, 'Listed', _formatDate(house.createdAt!)),
      if (house.updatedAt != null)
        _InfoItem(Icons.update, 'Last updated', _formatDate(house.updatedAt!)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 640 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: columns == 1 ? 5.4 : 4.4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) => items[index],
        );
      },
    );
  }

  String _formatAddress(House house) {
    return [
      house.address,
      house.city,
      if (house.state != null) house.state,
      if (house.zipCode != null) house.zipCode,
    ].whereType<String>().where((value) => value.isNotEmpty).join(', ');
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  String _statusLabel(House house) {
    final status = house.availabilityStatus.toLowerCase();
    return status == 'available' ? 'Available' : 'Rented';
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.year}-${_twoDigits(local.month)}-${_twoDigits(local.day)}';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSecondaryContainer),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
