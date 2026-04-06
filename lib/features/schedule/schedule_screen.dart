import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers.dart';
import '../../data/mock/buses_mock.dart';
import '../../data/mock/stations_mock.dart';
import '../../data/models/bus_line.dart';
import '../../l10n/app_localizations.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.read(localeStringProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.busSchedules,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: allBusLines.length,
        itemBuilder: (context, index) {
          final line = allBusLines[index];
          return _BusLineCard(line: line, code: code);
        },
      ),
    );
  }
}

class _BusLineCard extends StatefulWidget {
  final BusLine line;
  final String code;

  const _BusLineCard({required this.line, required this.code});

  @override
  State<_BusLineCard> createState() => _BusLineCardState();
}

class _BusLineCardState extends State<_BusLineCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final line = widget.line;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _expanded = !_expanded),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(22),
              ),
              alignment: Alignment.center,
              child: Text(
                line.lineNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            title: Text(
              '${line.directionFrom} \u2192 ${line.directionTo}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Every ${line.intervalMinutes}min \u00B7 ${line.startHour}:${line.startMinute.toString().padLeft(2, '0')} \u2013 ${line.endHour}:${line.endMinute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 13),
            ),
            trailing: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            _buildNextDepartures(),
            const Divider(height: 1),
            _buildStationList(),
          ],
        ],
      ),
    );
  }

  Widget _buildNextDepartures() {
    final line = widget.line;
    final next = line.getNextDepartures(count: 5);
    final now = DateTime.now();

    String formatTime(DateTime d) {
      return '${d.hour}:${d.minute.toString().padLeft(2, '0')}';
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Next Departures',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          if (next.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No more departures today'),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: next.map((dep) {
                final mins = dep.difference(now).inMinutes;
                return Chip(
                  label: Text(
                    '${formatTime(dep)} ($mins min)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: mins <= 5 ? Colors.green : null,
                    ),
                  ),
                  backgroundColor: mins <= 5
                      ? Colors.green.withOpacity(0.1)
                      : null,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStationList() {
    final line = widget.line;
    final code = widget.code;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stations',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          for (var i = 0; i < line.stationIds.length; i++) ...[
            if (i > 0)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 12,
                  width: 2,
                  color: AppColors.primary.withOpacity(0.3),
                  margin: const EdgeInsets.only(left: 11.5),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    i == 0
                        ? Icons.circle
                        : i == line.stationIds.length - 1
                            ? Icons.flag
                            : Icons.radio_button_unchecked,
                    size: 24,
                    color: i == 0
                        ? Colors.green
                        : i == line.stationIds.length - 1
                            ? Colors.red
                            : AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      allStations[line.stationIds[i]]?.nameForLocale(code) ?? '?',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
