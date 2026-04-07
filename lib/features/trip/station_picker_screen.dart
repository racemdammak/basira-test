import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers.dart';
import '../../data/models/station.dart';
import '../../data/mock/stations_mock.dart';
import '../../data/mock/buses_mock.dart';
import 'trip_planner_screen.dart';

class StationPickerScreen extends ConsumerStatefulWidget {
  final Station? preselectedOrigin;
  final Station? preselectedDestination;

  const StationPickerScreen({
    super.key,
    this.preselectedOrigin,
    this.preselectedDestination,
  });

  @override
  ConsumerState<StationPickerScreen> createState() =>
      _StationPickerScreenState();
}

class _StationPickerScreenState extends ConsumerState<StationPickerScreen> {
  late Station? _origin;
  late Station? _destination;
  late final TextEditingController _originController = TextEditingController();
  late final TextEditingController _destController = TextEditingController();
  bool _selectingOrigin = true;

  @override
  void initState() {
    super.initState();
    final code = ref.read(localeStringProvider);
    _origin = widget.preselectedOrigin;
    _destination = widget.preselectedDestination;
    if (_origin != null) {
      _originController.text = _origin!.nameForLocale(code);
    }
    if (_destination != null) {
      _destController.text = _destination!.nameForLocale(code);
    }
  }

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
                l10n: l10n,
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
                l10n: l10n,
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
          color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                station != null ? Icons.location_on_rounded : Icons.location_on_outlined,
                size: 22,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    station != null
                        ? station.nameForLocale(ref.read(localeStringProvider))
                        : 'Tap to select',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: station != null ? FontWeight.w600 : FontWeight.normal,
                      color: station != null ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.navigate_next_rounded, color: AppColors.primaryLight),
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
    required AppLocalizations l10n,
    required Station selected,
    required Station? other,
    required String code,
    required bool isOriginSelected,
    required void Function(Station) onSelect,
  }) {
    final reachable = _getAllReachable(selected);
    if (reachable.isEmpty) return const SizedBox.shrink();

    final suggestionL10n = isOriginSelected ? l10n.suggestedDestinations : l10n.suggestedOrigins;
    final title = '$suggestionL10n ${selected.nameForLocale(code)}:';

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
      final suggestionL10n = suggestMode == _SuggestMode.destinations
          ? l10n.suggestedDestinations
          : l10n.suggestedOrigins;
      suggestionTitle = '$suggestionL10n ${suggestFrom.nameForLocale(code)}';
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.searchStation,
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
                    filled: true,
                    fillColor: const Color(0xFFF5F0D6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.accent.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: _search,
                  autofocus: true,
                ),
              ),
              // Suggestions section
              if (suggestions != null) ..._buildSuggestionList(suggestions, suggestionTitle ?? '', suggestMode, code),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(l10n.allStations, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ),
              // Search results
              Expanded(
                child: _results.isEmpty
                    ? Center(child: Text(l10n.typeToSearch))
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

  List<Widget> _buildSuggestionList(
    Map<String, Set<String>> suggestions,
    String suggestionTitle,
    _SuggestMode? suggestMode,
    String code,
  ) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          suggestionTitle,
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
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final stationId = suggestions.keys.elementAt(index);
            final lines = suggestions[stationId]!;
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
    ];
  }
}
