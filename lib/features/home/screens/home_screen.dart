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
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeNotifier>().loadHouses();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _navigateToDetails(int id) {
    context.go(AppRoutes.houseDetailsPath(id.toString()));
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
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'House Finder',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Find your perfect home',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          onChanged: _onSearchChanged,
                          decoration: const InputDecoration(
                            hintText: 'Search by neighborhood or city...',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Consumer<HomeNotifier>(
                          builder: (context, notifier, _) {
                            return _buildLocationControls(notifier);
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
                      HomeLoading() => const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      HomeSuccess() => _buildHouseList(
                          notifier.filteredHouses(_searchQuery),
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
            childAspectRatio: 0.72,
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

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
              'No houses found',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'Check back later for new listings'
                  : 'Try adjusting your search criteria',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
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
}
