import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers.dart';
import '../../data/models/station.dart';
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
                setState(() {
                  _selectingOrigin = true;
                });
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
                setState(() {
                  _selectingOrigin = false;
                });
                _showStationSearch(context);
              },
            ),
            const SizedBox(height: 24),
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
                  station.nameForLocale(
                      ref.read(localeStringProvider)),
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

  void _showStationSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _StationSearchSheet(
        onSelect: (Station station) {
          setState(() {
            if (_selectingOrigin) {
              _origin = station;
              _originController.text = station.nameForLocale(
                  ref.read(localeStringProvider));
            } else {
              _destination = station;
              _destController.text = station.nameForLocale(
                  ref.read(localeStringProvider));
            }
          });
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _StationSearchSheet extends ConsumerStatefulWidget {
  final void Function(Station station) onSelect;
  const _StationSearchSheet({required this.onSelect});

  @override
  ConsumerState<_StationSearchSheet> createState() =>
      _StationSearchSheetState();
}

class _StationSearchSheetState extends ConsumerState<_StationSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Station> _results = [];

  void _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        _results = [];
      });
      return;
    }
    final stations = await ref
        .read(busRepositoryProvider)
        .searchStations(query);
    setState(() {
      _results = stations;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: 400,
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
              Expanded(
                child: _results.isEmpty
                    ? const Center(child: Text('Stations'))
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final station = _results[index];
                          final name = station.nameForLocale(
                              ref.read(localeStringProvider));
                          return ListTile(
                            onTap: () {
                              widget.onSelect(station);
                            },
                            title: Text(name),
                            subtitle: Text(
                              'Lines: ${station.lineNumbers.join(", ")}',
                            ),
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
