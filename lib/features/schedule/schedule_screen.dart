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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
    final l10n = AppLocalizations.of(context);
    final line = widget.line;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _expanded = !_expanded),
            leading: _LineBadge(lineNumber: line.lineNumber),
            title: Text(
              '${line.directionFrom} \u2192 ${line.directionTo}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${l10n.everyXMin(line.intervalMinutes.toString())} \u00B7 ${line.startHour}:${line.startMinute.toString().padLeft(2, '0')} \u2013 ${line.endHour}:${line.endMinute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 13),
            ),
            trailing: Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded),
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
    final l10n = AppLocalizations.of(context);
    final line = widget.line;
    final next = line.getNextDepartures(count: 5);
    final now = DateTime.now();

    String formatTime(DateTime d) {
      return '${d.hour}:${d.minute.toString().padLeft(2, '0')}';
    }

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                l10n.nextDepartures,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (next.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.noMoreDepartures,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: next.map((dep) {
                final mins = dep.difference(now).inMinutes;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: mins <= 5
                        ? const Color(0xFFE8F3E5)
                        : const Color(0xFFF5F0D6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: mins <= 5
                          ? const Color(0xFFABCBA2)
                          : const Color(0xFFE8E0C8),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${formatTime(dep)} ($mins ${l10n.minAbbreviation})',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: mins <= 5 ? const Color(0xFF335836) : AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStationList() {
    final l10n = AppLocalizations.of(context);
    final line = widget.line;
    final code = widget.code;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                l10n.stations,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < line.stationIds.length; i++) ...[
            if (i > 0)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 14,
                  width: 2,
                  color: AppColors.primary.withOpacity(0.2),
                  margin: const EdgeInsets.only(left: 11),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StationDot(
                    isFirst: i == 0,
                    isLast: i == line.stationIds.length - 1,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      allStations[line.stationIds[i]]?.nameForLocale(code) ?? '?',
                      style: const TextStyle(fontSize: 14),
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

class _LineBadge extends StatelessWidget {
  final String lineNumber;

  const _LineBadge({required this.lineNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        lineNumber,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _StationDot extends StatelessWidget {
  final bool isFirst;
  final bool isLast;

  const _StationDot({required this.isFirst, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final isFilled = isFirst || isLast;
    final color = isFirst
        ? const Color(0xFF335836)
        : isLast
            ? const Color(0xFFD36868)
            : AppColors.primary;

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? color : Colors.transparent,
        border: isFilled ? null : Border.all(color: AppColors.primary, width: 2),
      ),
      alignment: Alignment.center,
      child: isFirst
          ? const Icon(Icons.flag, size: 12, color: Colors.white)
          : isLast
              ? const Icon(Icons.flag_rounded, size: 12, color: Colors.white)
              : Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
    );
  }
}
