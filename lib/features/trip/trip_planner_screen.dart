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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF335836),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 160,
                          child: Text(
                            trip.origin.nameForLocale(widget.code),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.arrow_downward_rounded, size: 16, color: AppColors.primaryLight),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD36868),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 160,
                          child: Text(
                            trip.destination.nameForLocale(widget.code),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A4A30) : const Color(0xFFE8F3E5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer_outlined, size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            '$minutes ${l10n.minutes}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (firstEstimate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          firstEstimate.formattedFare,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFFB0C4AE) : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Divider
            Container(
              height: 1,
              color: isDark ? const Color(0xFF2A3A2E) : const Color(0xFFE8E0C8),
            ),
            const SizedBox(height: 10),
            // Sections
            for (final section in trip.sections)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.directions_bus_rounded, size: 18, color: AppColors.primaryLight),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.lineLabel(section.busLineNumber),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${section.duration.inMinutes} ${l10n.minutes}',
                      style: TextStyle(
                        color: isDark ? const Color(0xFFB0C4AE) : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            // Favorite + Take This Bus row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.directions_bus_rounded, size: 20),
                    label: Text(l10n.takeThisBus),
                    onPressed: () {
                      // FIXED: Using the new ActiveTripState constructor with the 'trip' object
                      ref.read(activeTripProvider.notifier).state = ActiveTripState(
                        trip: trip,
                        currentLegIndex: 0,
                        isBoarded: false,
                      );
                      
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
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isFavorited ? AppColors.primary : (isDark ? const Color(0xFF3A5040) : Colors.grey.shade300),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
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
                    icon: Icon(
                      isFavorited ? Icons.star_rounded : Icons.star_border_rounded,
                      color: isFavorited ? AppColors.primary : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}