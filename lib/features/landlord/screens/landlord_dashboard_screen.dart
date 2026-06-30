import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/routes.dart';
import '../../../models/house.dart';
import '../../home/providers/home_notifier.dart';
import '../../home/providers/home_state.dart';

class LandlordDashboardScreen extends StatefulWidget {
  const LandlordDashboardScreen({super.key});

  @override
  State<LandlordDashboardScreen> createState() =>
      _LandlordDashboardScreenState();
}

class _LandlordDashboardScreenState extends State<LandlordDashboardScreen> {
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

  Future<void> _refreshListings() {
    return context.read<HomeNotifier>().refreshHouses();
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
        title: const Text('Landlord Dashboard'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshListings,
          child: Consumer<HomeNotifier>(
            builder: (context, notifier, _) {
              final state = notifier.state;
              final stats = _ListingStats.fromHouses(notifier.allHouses);

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isCompact = constraints.maxWidth < 620;

                              return Flex(
                                direction: isCompact
                                    ? Axis.vertical
                                    : Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isCompact)
                                    _DashboardHeaderCopy(
                                      theme: theme,
                                      colorScheme: colorScheme,
                                    )
                                  else
                                    Expanded(
                                      child: _DashboardHeaderCopy(
                                        theme: theme,
                                        colorScheme: colorScheme,
                                      ),
                                    ),
                                  SizedBox(
                                    width: isCompact ? 0 : 12,
                                    height: isCompact ? 14 : 0,
                                  ),
                                  FilledButton.icon(
                                    onPressed: () {
                                      context.go(AppRoutes.createListing);
                                    },
                                    icon: const Icon(
                                      Icons.add_home_work_outlined,
                                    ),
                                    label: const Text('Create Listing'),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          if (state is HomeLoading &&
                              notifier.allHouses.isEmpty) ...[
                            const _DashboardLoading(),
                          ] else ...[
                            _StatsGrid(stats: stats),
                            if (notifier.listMessage != null) ...[
                              const SizedBox(height: 12),
                              _DashboardNotice(message: notifier.listMessage!),
                            ],
                            if (state is HomeError &&
                                notifier.allHouses.isEmpty) ...[
                              const SizedBox(height: 16),
                              _DashboardError(
                                message: state.message,
                                onRetry: notifier.loadHouses,
                              ),
                            ] else ...[
                              const SizedBox(height: 24),
                              _ListingsSummary(stats: stats),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DashboardHeaderCopy extends StatelessWidget {
  const _DashboardHeaderCopy({
    required this.theme,
    required this.colorScheme,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage listings',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Track listing status and add new properties.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final _ListingStats stats;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = width >= 900 ? 4 : width >= 620 ? 2 : 1;

    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: width >= 620 ? 1.75 : 3.3,
      children: [
        _StatTile(
          label: 'Total Listings',
          value: stats.total,
          icon: Icons.inventory_2_outlined,
        ),
        _StatTile(
          label: 'Published Listings',
          value: stats.published,
          icon: Icons.public_outlined,
        ),
        _StatTile(
          label: 'Pending Listings',
          value: stats.pending,
          icon: Icons.pending_actions_outlined,
        ),
        _StatTile(
          label: 'Rented Listings',
          value: stats.rented,
          icon: Icons.key_outlined,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value.toString(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
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

class _ListingsSummary extends StatelessWidget {
  const _ListingsSummary({required this.stats});

  final _ListingStats stats;

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
            Text(
              'Listing overview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _StatusRow(label: 'Published listings', value: stats.published),
            const Divider(height: 20),
            _StatusRow(label: 'Pending listings', value: stats.pending),
            const Divider(height: 20),
            _StatusRow(label: 'Rented listings', value: stats.rented),
            if (stats.total == 0) ...[
              const SizedBox(height: 16),
              Text(
                'No listings yet. Create your first property listing to start '
                'tracking status here.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          value.toString(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: colorScheme.error,
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              'Could not load dashboard',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardNotice extends StatelessWidget {
  const _DashboardNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: colorScheme.onSecondaryContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colorScheme.onSecondaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingStats {
  const _ListingStats({
    required this.total,
    required this.published,
    required this.pending,
    required this.rented,
  });

  final int total;
  final int published;
  final int pending;
  final int rented;

  factory _ListingStats.fromHouses(List<House> houses) {
    var published = 0;
    var pending = 0;
    var rented = 0;

    for (final house in houses) {
      final status = house.availabilityStatus.toLowerCase().trim();
      if (_pendingStatuses.contains(status)) {
        pending++;
      } else if (_rentedStatuses.contains(status)) {
        rented++;
      } else if (_publishedStatuses.contains(status) || status.isNotEmpty) {
        published++;
      }
    }

    return _ListingStats(
      total: houses.length,
      published: published,
      pending: pending,
      rented: rented,
    );
  }

  static const _publishedStatuses = {
    'available',
    'active',
    'approved',
    'listed',
    'published',
  };

  static const _pendingStatuses = {
    'draft',
    'in_review',
    'pending',
    'pending_review',
    'unpublished',
  };

  static const _rentedStatuses = {
    'leased',
    'occupied',
    'rented',
  };
}
