import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers.dart';
import '../../data/mock/buses_mock.dart';
import '../../data/models/bus_line.dart';
import '../../l10n/app_localizations.dart';

enum _CrowdLevel { high, moderate, low }

String _crowdLabel(AppLocalizations l10n, _CrowdLevel level) {
  switch (level) {
    case _CrowdLevel.high:
      return l10n.veryCrowded;
    case _CrowdLevel.moderate:
      return l10n.moderate;
    case _CrowdLevel.low:
      return l10n.usuallyAvailable;
  }
}

Color _crowdColor(_CrowdLevel level, {double alpha = 1.0}) {
  final c = switch (level) {
    _CrowdLevel.high => Colors.red,
    _CrowdLevel.moderate => Colors.orange,
    _CrowdLevel.low => Colors.green,
  };
  return alpha < 1.0 ? c.withValues(alpha: alpha) : c;
}

_CrowdLevel _getExpectedCrowdingLevel(int hour) {
  if (hour >= 7 && hour <= 9) return _CrowdLevel.high;
  if (hour >= 12 && hour <= 14) return _CrowdLevel.moderate;
  if (hour >= 16 && hour <= 18) return _CrowdLevel.high;
  return _CrowdLevel.low;
}

class CrowdPatternsScreen extends ConsumerWidget {
  const CrowdPatternsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.read(localeStringProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.crowdPatterns),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: allBusLines.length,
        itemBuilder: (context, index) {
          final line = allBusLines[index];
          return _LineCrowdCard(line: line, code: code);
        },
      ),
    );
  }
}

class _LineCrowdCard extends StatelessWidget {
  final BusLine line;
  final String code;

  const _LineCrowdCard({required this.line, required this.code});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now().hour;
    final expected = _getExpectedCrowdingLevel(now);

    final timeSlots = <(_CrowdLevel, String)>[];
    for (var h = line.startHour; h <= line.endHour; h++) {
      final level = _getExpectedCrowdingLevel(h);
      timeSlots.add((level, '$h:00'));
    }

    return Card(
      margin: const EdgeInsets.all(12),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            line.lineNumber,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        title: Text('${line.directionFrom} \u2192 ${line.directionTo}'),
        subtitle: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _crowdColor(expected),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text('${l10n.rightNow}: ${_crowdLabel(l10n, expected)}'),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Text(
              l10n.expectedCrowding,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _CrowdTimeline(slots: timeSlots, l10n: l10n),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _CrowdTimeline extends StatelessWidget {
  final List<(_CrowdLevel, String)> slots;
  final AppLocalizations l10n;

  const _CrowdTimeline({required this.slots, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: slots.map((slot) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(slot.$2,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: _crowdColor(slot.$1, alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: Text(_crowdLabel(l10n, slot.$1), style: const TextStyle(fontSize: 11)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
