import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/routes.dart';
import '../../../models/house.dart';
import '../providers/home_notifier.dart';
import '../providers/home_state.dart';
import '../widgets/house_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  HomeFilters _filters = const HomeFilters();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeNotifier>().loadHouses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _navigateToDetails(int id) {
    context.go(AppRoutes.houseDetailsPath(id.toString()));
  }

  void _resetFilters() {
    setState(() {
      _filters = const HomeFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;
    final crossAxisCount = screenWidth > 900 ? 3 : 2;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: RefreshIndicator(
              onRefresh: () => context.read<HomeNotifier>().refreshHouses(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'House Finder',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Find available homes by neighborhood, budget, and type.',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () {
                              context.go(AppRoutes.landlordRegistration);
                            },
                            icon: const Icon(Icons.add_home_work_outlined),
                            label: const Text('List a property'),
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'Search neighborhood...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchQuery.isEmpty
                                  ? null
                                  : IconButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        _onSearchChanged('');
                                      },
                                      icon: const Icon(Icons.close),
                                      tooltip: 'Clear search',
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Consumer<HomeNotifier>(
                            builder: (context, notifier, _) {
                              final state = notifier.state;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFilterControls(notifier),
                                  const SizedBox(height: 12),
                                  _buildLocationControls(notifier),
                                  if (notifier.listMessage != null) ...[
                                    const SizedBox(height: 10),
                                    _buildNotice(notifier.listMessage!),
                                  ],
                                  if (state is HomeSuccess &&
                                      state.notice != null) ...[
                                    const SizedBox(height: 10),
                                    _buildNotice(state.notice!),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Consumer<HomeNotifier>(
                    builder: (context, notifier, _) {
                      return switch (notifier.state) {
                        HomeInitial() => const SliverFillRemaining(
                            hasScrollBody: false,
                            child: SizedBox.shrink(),
                          ),
                        HomeLoading() => _SkeletonHouseList(
                            isWide: isWide,
                            crossAxisCount: crossAxisCount,
                          ),
                        HomeSuccess() => _buildHouseList(
                            notifier.filteredHouses(_searchQuery, _filters),
                            isWide,
                            crossAxisCount,
                            notifier,
                          ),
                        HomeError(:final message) => SliverFillRemaining(
                            hasScrollBody: false,
                            child: _buildErrorState(message, notifier),
                          ),
                      };
                    },
                  ),
                  const SliverPadding(
                    padding: EdgeInsets.only(bottom: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHouseList(
    List<House> houses,
    bool isWide,
    int crossAxisCount,
    HomeNotifier notifier,
  ) {
    if (houses.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEmptyState(),
      );
    }

    if (isWide) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.74,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => HouseListItem(
              house: houses[index],
              distanceKm: notifier.distanceForHouse(houses[index]),
              onTap: () => _navigateToDetails(houses[index].id),
            ),
            childCount: houses.length,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: HouseListItem(
              house: houses[index],
              distanceKm: notifier.distanceForHouse(houses[index]),
              onTap: () => _navigateToDetails(houses[index].id),
            ),
          ),
          childCount: houses.length,
        ),
      ),
    );
  }

  Widget _buildFilterControls(HomeNotifier notifier) {
    if (notifier.allHouses.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final minPrice = notifier.minHousePrice;
    final maxPrice = notifier.maxHousePrice;
    final selectedRange = _filters.priceRange ?? RangeValues(minPrice, maxPrice);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _filters.propertyType,
                decoration: const InputDecoration(
                  labelText: 'Property type',
                  prefixIcon: Icon(Icons.apartment),
                ),
                items: notifier.propertyTypes
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(
                          _capitalize(type),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  setState(() {
                    _filters = _filters.copyWith(
                      propertyType: value,
                      clearPropertyType: value == null,
                    );
                  });
                },
              ),
            ),
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: _filters.bedrooms,
                decoration: const InputDecoration(
                  labelText: 'Bedrooms',
                  prefixIcon: Icon(Icons.bed),
                ),
                items: notifier.bedroomCounts
                    .map(
                      (count) => DropdownMenuItem(
                        value: count,
                        child: Text(
                          '$count bed${count == 1 ? '' : 's'}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  setState(() {
                    _filters = _filters.copyWith(
                      bedrooms: value,
                      clearBedrooms: value == null,
                    );
                  });
                },
              ),
            ),
            TextButton.icon(
              onPressed: _filters.hasActiveFilters ? _resetFilters : null,
              icon: const Icon(Icons.filter_alt_off),
              label: const Text('Reset filters'),
            ),
          ],
        ),
        if (maxPrice > minPrice) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.payments_outlined,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RangeSlider(
                  min: minPrice,
                  max: maxPrice,
                  values: selectedRange,
                  divisions: 20,
                  labels: RangeLabels(
                    '${_formatPrice(selectedRange.start)} FCFA',
                    '${_formatPrice(selectedRange.end)} FCFA',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _filters = _filters.copyWith(priceRange: value);
                    });
                  },
                ),
              ),
            ],
          ),
          Text(
            '${_formatPrice(selectedRange.start)} - '
            '${_formatPrice(selectedRange.end)} FCFA',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationControls(HomeNotifier notifier) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final message = notifier.locationMessage;

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: notifier.refreshLocation,
          icon: const Icon(Icons.my_location),
          label: Text(
            notifier.userLocation == null ? 'Use location' : 'Refresh location',
          ),
        ),
        if (notifier.userLocation != null)
          Text(
            'Sorted by distance',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          )
        else if (message != null)
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.error,
            ),
          ),
      ],
    );
  }

  Widget _buildNotice(String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasQueryOrFilters =
        _searchQuery.trim().isNotEmpty || _filters.hasActiveFilters;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              hasQueryOrFilters ? 'No results found' : 'No houses found',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasQueryOrFilters
                  ? 'Try adjusting your search or filters'
                  : 'Check back later for new listings',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasQueryOrFilters) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                  _resetFilters();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Clear search and filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, HomeNotifier notifier) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: notifier.retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
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
}

class _SkeletonHouseList extends StatelessWidget {
  final bool isWide;
  final int crossAxisCount;

  const _SkeletonHouseList({
    required this.isWide,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.74,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => const _SkeletonHouseCard(),
            childCount: crossAxisCount * 2,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: _SkeletonHouseCard(),
          ),
          childCount: 4,
        ),
      ),
    );
  }
}

class _SkeletonHouseCard extends StatefulWidget {
  const _SkeletonHouseCard();

  @override
  State<_SkeletonHouseCard> createState() => _SkeletonHouseCardState();
}

class _SkeletonHouseCardState extends State<_SkeletonHouseCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.45, end: 0.82).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;

    return FadeTransition(
      opacity: _opacity,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonBlock(height: 180, width: double.infinity, color: color),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBlock(height: 18, width: 190, color: color),
                  const SizedBox(height: 10),
                  _SkeletonBlock(height: 14, width: 240, color: color),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _SkeletonBlock(height: 24, width: 72, color: color),
                      const SizedBox(width: 10),
                      _SkeletonBlock(height: 24, width: 72, color: color),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  final double height;
  final double width;
  final Color color;

  const _SkeletonBlock({
    required this.height,
    required this.width,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
