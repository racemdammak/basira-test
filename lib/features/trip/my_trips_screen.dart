import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers.dart';
import '../../data/mock/stations_mock.dart';
import '../../data/mock/buses_mock.dart';
import '../../data/services/storage_service.dart';
import '../../l10n/app_localizations.dart';
import 'trip_planner_screen.dart';
import 'station_picker_screen.dart';

class MyTripsScreen extends ConsumerStatefulWidget {
  const MyTripsScreen({super.key});

  @override
  ConsumerState<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends ConsumerState<MyTripsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final code = ref.read(localeStringProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.myTrips),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(icon: Icon(Icons.star), text: l10n.favorites),
            Tab(icon: Icon(Icons.history), text: l10n.history),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FavoritesTab(code: code),
          _HistoryTab(code: code),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const StationPickerScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FavoritesTab extends ConsumerWidget {
  final String code;
  const _FavoritesTab({required this.code});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    if (favorites.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_border, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(l10n.noFavoritesYet),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final fav = favorites[index];
        final origin = allStations[fav.originId];
        final dest = allStations[fav.destinationId];
        if (origin == null || dest == null) return const SizedBox.shrink();

        final servingLines = allBusLines.where((line) {
          final oi = line.stationIds.indexOf(fav.originId);
          final di = line.stationIds.indexOf(fav.destinationId);
          return oi != -1 && di != -1 && oi != di;
        }).toList();

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const SizedBox(
              width: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.circle, size: 12, color: Colors.green),
                  SizedBox(height: 4),
                  SizedBox(width: 2, height: 16, child: VerticalDivider()),
                  SizedBox(height: 4),
                  Icon(Icons.flag, size: 12, color: Colors.red),
                ],
              ),
            ),
            title: Text(origin.nameForLocale(code)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\u2193 ${dest.nameForLocale(code)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                if (servingLines.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: servingLines.map((line) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Line ${line.lineNumber}',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                ref.read(storageServiceProvider).removeFavorite(fav.id);
                if (context.mounted) {
                  ref.read(favoritesProvider.notifier).state =
                      ref.read(storageServiceProvider).getFavorites();
                }
              },
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TripPlannerScreen(
                    origin: origin,
                    destination: dest,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  final String code;
  const _HistoryTab({required this.code});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(tripHistoryProvider);

    if (history.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(l10n.noTripHistoryYet),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final entry = history[index];
        final origin = allStations[entry.originId];
        final dest = allStations[entry.destinationId];
        if (origin == null || dest == null) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              entry.busLineUsed != null
                  ? Icons.directions_bus
                  : Icons.location_on_outlined,
              color: AppColors.primary,
            ),
            title: Text('${origin.nameForLocale(code)} \u2192 ${dest.nameForLocale(code)}'),
            subtitle: Text(
              '${_formatDate(entry.date)}${entry.busLineUsed != null ? ' \u00B7 Line ${entry.busLineUsed}' : ''}',
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TripPlannerScreen(
                    origin: origin,
                    destination: dest,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
