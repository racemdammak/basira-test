import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers.dart';
import '../../data/models/bus_line.dart';
import '../../data/models/station.dart';
import '../../data/mock/stations_mock.dart';
import '../../data/mock/buses_mock.dart';
import 'trip_planner_screen.dart';

class StationPickerScreen extends ConsumerStatefulWidget {
  const StationPickerScreen({super.key});

  @override
  ConsumerState<StationPickerScreen> createState() =>
      _StationPickerScreenState();
}

class _StationPickerScreenState extends ConsumerState<StationPickerScreen> {
  Station? _origin;
  Station? _destination;
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destController = TextEditingController();
  bool _selectingOrigin = true;

  @override
  void dispose() {
    _originController.dispose();
    _destController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final code = ref.read(localeStringProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.selectStation),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Origin selection
            _buildStationPicker(
              label: l10n.selectOrigin,
              station: _origin,
              controller: _originController,
              onTap: () {
                setState(() => _selectingOrigin = true);
                _showStationSearch(context);
              },
            ),
            const SizedBox(height: 16),
            // Destination selection
            _buildStationPicker(
              label: l10n.selectDestination,
              station: _destination,
              controller: _destController,
              onTap: () {
                setState(() => _selectingOrigin = false);
                _showStationSearch(context);
              },
            ),
            const SizedBox(height: 16),
            // Suggestions: show destinations if origin selected, origins if destination selected
            if (_origin != null && _destination == null)
              _buildSuggestions(
                selected: _origin!,
                other: _destination,
                code: code,
                isOriginSelected: true,
                onSelect: (station) {
                  setState(() {
                    _destination = station;
                    _destController.text = station.nameForLocale(code);
                  });
                },
              )
            else if (_destination != null && _origin == null)
              _buildSuggestions(
                selected: _destination!,
                other: _origin,
                code: code,
                isOriginSelected: false,
                onSelect: (station) {
                  setState(() {
                    _origin = station;
                    _originController.text = station.nameForLocale(code);
                  });
                },
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_origin != null && _destination != null)
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TripPlannerScreen(
                              origin: _origin!,
                              destination: _destination!,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(l10n.findRoute),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationPicker({
    required String label,
    required Station? station,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            if (station != null)
              Expanded(
                child: Text(
                  station.nameForLocale(ref.read(localeStringProvider)),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else
              const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// Build suggestions list: reachable stations from a station on shared lines.
  /// If [forward] is true, show stations after the given one; if false, show stations before.
  Map<String, Set<String>> _getReachable(Station station, {bool forward = true}) {
    final reachable = <String, Set<String>>{};
    final servingLines = allBusLines.where((line) {
      return line.stationIds.contains(station.id);
    }).toList();
    for (final line in servingLines) {
      final idx = line.stationIds.indexOf(station.id);
      if (idx == -1) continue;
      if (forward) {
        for (var i = idx + 1; i < line.stationIds.length; i++) {
          reachable.putIfAbsent(line.stationIds[i], () => {}).add(line.lineNumber);
        }
      } else {
        for (var i = 0; i < idx; i++) {
          reachable.putIfAbsent(line.stationIds[i], () => {}).add(line.lineNumber);
        }
      }
    }
    return reachable;
  }

  /// Combined reachable stations (both directions) from [station].
  Map<String, Set<String>> _getAllReachable(Station station) {
    final reachable = _getReachable(station, forward: true);
    final backward = _getReachable(station, forward: false);
    for (final entry in backward.entries) {
      reachable.putIfAbsent(entry.key, () => {}).addAll(entry.value);
    }
    return reachable;
  }

  /// Show suggestions when a station is selected.
  /// If origin is set → suggest destinations. If destination is set → suggest origins.
  Widget _buildSuggestions({
    required Station selected,
    required Station? other,
    required String code,
    required bool isOriginSelected,
    required void Function(Station) onSelect,
  }) {
    final reachable = _getAllReachable(selected);
    if (reachable.isEmpty) return const SizedBox.shrink();

    final title = isOriginSelected
        ? 'Stations from ${selected.nameForLocale(code)}:'
        : 'Origins to ${selected.nameForLocale(code)}:';

    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: reachable.length,
              itemBuilder: (context, index) {
                final stationId = reachable.keys.elementAt(index);
                final lines = reachable[stationId]!;
                final station = allStations[stationId];
                if (station == null) return const SizedBox.shrink();
                final isSelected = other?.id == station.id;

                return ListTile(
                  leading: Icon(
                    isOriginSelected ? Icons.location_on_outlined : Icons.my_location,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    station.nameForLocale(code),
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: Wrap(
                    spacing: 4,
                    children: lines.map((ln) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('L$ln',
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary)),
                      );
                    }).toList(),
                  ),
                  selected: isSelected,
                  onTap: () => onSelect(station),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showStationSearch(BuildContext context) {
    final code = ref.read(localeStringProvider);
    final hasOther = _selectingOrigin
        ? _destination != null
        : _origin != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _StationSearchSheet(
        onSelect: (Station station) {
          setState(() {
            if (_selectingOrigin) {
              _origin = station;
              _originController.text = station.nameForLocale(code);
            } else {
              _destination = station;
              _destController.text = station.nameForLocale(code);
            }
          });
          Navigator.pop(context);
        },
        suggestFrom: hasOther
            ? (_selectingOrigin ? _destination! : _origin!)
            : null,
        suggestMode: hasOther
            ? (_selectingOrigin ? _SuggestMode.origins : _SuggestMode.destinations)
            : null,
      ),
    );
  }
}

enum _SuggestMode { origins, destinations }

class _StationSearchSheet extends ConsumerStatefulWidget {
  final void Function(Station station) onSelect;
  final Station? suggestFrom;
  final _SuggestMode? suggestMode;

  const _StationSearchSheet({
    required this.onSelect,
    this.suggestFrom,
    this.suggestMode,
  });

  @override
  ConsumerState<_StationSearchSheet> createState() =>
      _StationSearchSheetState();
}

class _StationSearchSheetState extends ConsumerState<_StationSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Station> _results = [];

  Map<String, Set<String>> _getReachable(Station station, {bool forward = true}) {
    final reachable = <String, Set<String>>{};
    final servingLines = allBusLines.where((line) {
      return line.stationIds.contains(station.id);
    }).toList();
    for (final line in servingLines) {
      final idx = line.stationIds.indexOf(station.id);
      if (idx == -1) continue;
      if (forward) {
        for (var i = idx + 1; i < line.stationIds.length; i++) {
          reachable.putIfAbsent(line.stationIds[i], () => {}).add(line.lineNumber);
        }
      } else {
        for (var i = 0; i < idx; i++) {
          reachable.putIfAbsent(line.stationIds[i], () => {}).add(line.lineNumber);
        }
      }
    }
    return reachable;
  }

  Map<String, Set<String>> _getAllReachable(Station station) {
    final reachable = _getReachable(station, forward: true);
    final backward = _getReachable(station, forward: false);
    for (final entry in backward.entries) {
      reachable.putIfAbsent(entry.key, () => {}).addAll(entry.value);
    }
    return reachable;
  }

  void _search(String query) {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }
    final q = query.toLowerCase();
    final stations = allStations.values.where((s) {
      return s.nameFr.toLowerCase().contains(q) ||
          s.nameAr.contains(q) ||
          s.nameTun.contains(q) ||
          s.id.contains(q);
    }).toList();
    setState(() => _results = stations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final code = ref.read(localeStringProvider);
    final suggestFrom = widget.suggestFrom;
    final suggestMode = widget.suggestMode;

    Map<String, Set<String>>? suggestions;
    String? suggestionTitle;
    if (suggestFrom != null && suggestMode != null) {
      suggestions = _getAllReachable(suggestFrom);
      suggestionTitle = suggestMode == _SuggestMode.destinations
          ? 'Suggested destinations from ${suggestFrom.nameForLocale(code)}'
          : 'Suggested origins to ${suggestFrom.nameForLocale(code)}';
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.searchStation,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: _search,
                  autofocus: true,
                ),
              ),
              // Suggestions section
              if (suggestions != null && suggestions!.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    suggestionTitle!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: suggestions!.length,
                    itemBuilder: (context, index) {
                      final stationId = suggestions!.keys.elementAt(index);
                      final lines = suggestions![stationId]!;
                      final station = allStations[stationId];
                      if (station == null) return const SizedBox.shrink();
                      return ListTile(
                        leading: Icon(
                          suggestMode == _SuggestMode.destinations
                              ? Icons.location_on_outlined
                              : Icons.my_location,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        title: Text(station.nameForLocale(code)),
                        trailing: Wrap(
                          spacing: 4,
                          children: lines.map((ln) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('L$ln',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary)),
                            );
                          }).toList(),
                        ),
                        onTap: () => widget.onSelect(station),
                      );
                    },
                  ),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('All stations', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ),
              ],
              // Search results
              Expanded(
                child: _results.isEmpty
                    ? const Center(child: Text('Type to search...'))
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final station = _results[index];
                          return ListTile(
                            onTap: () => widget.onSelect(station),
                            title: Text(station.nameForLocale(code)),
                            subtitle: Text('Lines: ${station.lineNumbers.join(", ")}'),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
