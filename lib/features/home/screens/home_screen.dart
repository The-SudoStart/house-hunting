import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/routes.dart';
import '../../../models/house.dart';
import '../../../services/house_service.dart';
import '../widgets/house_list_item.dart';

/// The application's primary screen for browsing available house listings.
///
/// Features:
/// * Application header with branding.
/// * Real-time search filtering by title, city, or address.
/// * Responsive scrolling list (or grid on wide screens).
/// * Loading state while data is fetched.
/// * Empty state when no listings match the query.
/// * Error handling with SnackBar notification and retry option.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  List<House> _allHouses = [];
  List<House> _filteredHouses = [];
  String _searchQuery = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHouses();
  }

  Future<void> _loadHouses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final houses = await HouseService.getHouses();
      setState(() {
        _allHouses = houses;
        _filteredHouses = houses;
        _isLoading = false;
      });
    } catch (e) {
      final message =
          'Failed to load houses. Please check your connection and try again.';
      setState(() {
        _isLoading = false;
        _errorMessage = message;
        _allHouses = [];
        _filteredHouses = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadHouses,
            ),
          ),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredHouses = _allHouses;
      } else {
        final searchLower = query.toLowerCase();
        _filteredHouses = _allHouses.where((house) {
          return house.title.toLowerCase().contains(searchLower) ||
              house.city.toLowerCase().contains(searchLower) ||
              house.address.toLowerCase().contains(searchLower);
        }).toList();
      }
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
                // Application header + search
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
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                      ],
                    ),
                  ),
                ),
                // Content area
                if (_isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_filteredHouses.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                else if (isWide)
                  SliverPadding(
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
                          house: _filteredHouses[index],
                          onTap: () => _navigateToDetails(
                            _filteredHouses[index].id,
                          ),
                        ),
                        childCount: _filteredHouses.length,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: HouseListItem(
                            house: _filteredHouses[index],
                            onTap: () => _navigateToDetails(
                              _filteredHouses[index].id,
                            ),
                          ),
                        ),
                        childCount: _filteredHouses.length,
                      ),
                    ),
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
              _errorMessage != null ? Icons.error_outline : Icons.home_work_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage != null ? 'Something went wrong' : 'No houses found',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ??
                  (_searchQuery.isEmpty
                      ? 'Check back later for new listings'
                      : 'Try adjusting your search criteria'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadHouses,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
