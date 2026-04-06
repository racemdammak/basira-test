import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers.dart';
import '../../data/models/station.dart';
import '../../data/models/trip.dart';
import '../../data/models/favorite_route.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/travel_time_service.dart';
import 'trip_active_screen.dart';

class TripPlannerScreen extends ConsumerWidget {
  final Station origin;
  final Station destination;

  const TripPlannerScreen({
    super.key,
    required this.origin,
    required this.destination,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final code = ref.read(localeStringProvider);
    final search = TripSearch(originId: origin.id, destId: destination.id);
    final tripsAsync = ref.watch(tripOptionsProvider(search));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.routePlanned),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: tripsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.error)),
        data: (trips) {
          if (trips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_bus, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(l10n.noBuses),
                  const SizedBox(height: 8),
                  Text(l10n.tryAgainLater),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return _TripCard(trip: trip, code: code);
            },
          );
        },
      ),
    );
  }
}

class _TripCard extends ConsumerStatefulWidget {
  final Trip trip;
  final String code;

  const _TripCard({required this.trip, required this.code});

  @override
  ConsumerState<_TripCard> createState() => _TripCardState();
}

class _TripCardState extends ConsumerState<_TripCard> {
  bool isFavorited = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final trip = widget.trip;
    final minutes = trip.totalDuration.inMinutes;

    // Check if already favorited
    final storage = ref.read(storageServiceProvider);
    isFavorited = storage.getFavorites().any(
      (f) => f.originId == trip.origin.id && f.destinationId == trip.destination.id,
    );

    // Get travel estimate
    final estimates = ref.watch(
      travelEstimateProvider((originId: trip.origin.id, destinationId: trip.destination.id)),
    );
    final firstEstimate = estimates.isNotEmpty ? estimates.first : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.origin.nameForLocale(widget.code),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Text('\u2193', textAlign: TextAlign.center),
                      Text(
                        trip.destination.nameForLocale(widget.code),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$minutes min',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (firstEstimate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          firstEstimate.formattedFare,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Sections
            for (final section in trip.sections)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'L${section.busLineNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${section.duration.inMinutes}min'),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            // Favorite + Take This Bus row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(activeTripProvider.notifier).state =
                          ref.read(activeTripProvider).copyWith(
                                originId: trip.origin.id,
                                destinationId: trip.destination.id,
                              );
                      // Add to history
                      storage.addToHistory(TripHistoryEntry(
                        originId: trip.origin.id,
                        destinationId: trip.destination.id,
                        date: DateTime.now(),
                        busLineUsed: trip.sections.first.busLineNumber,
                      ));
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TripActiveScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.directions_bus),
                    label: Text(l10n.takeThisBus),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    final favId = '${trip.origin.id}_${trip.destination.id}';
                    if (isFavorited) {
                      ref.read(storageServiceProvider).removeFavorite(favId);
                    } else {
                      ref.read(storageServiceProvider).addFavorite(
                        FavoriteRoute(
                          id: favId,
                          originId: trip.origin.id,
                          destinationId: trip.destination.id,
                          createdAt: DateTime.now(),
                        ),
                      );
                    }
                    if (mounted) {
                      ref.read(favoritesProvider.notifier).state =
                          storage.getFavorites();
                      setState(() => isFavorited = !isFavorited);
                    }
                  },
                  icon: Icon(isFavorited ? Icons.star : Icons.star_border),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
