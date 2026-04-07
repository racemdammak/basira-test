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

/// Gradient badge widget matching schedule screen style.
class _LineBadge extends StatelessWidget {
  final String label;

  const _LineBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

class CrowdPatternsScreen extends ConsumerWidget {
  const CrowdPatternsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.read(localeStringProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.crowdPatterns),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
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
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: 0.1),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.fromLTRB(12, 4, 8, 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.primaryLight,
        leading: _LineBadge(label: line.lineNumber),
        title: Text(
          '${line.directionFrom} \u2192 ${line.directionTo}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 13,
              color: _crowdColor(expected),
            ),
            const SizedBox(width: 4),
            Text(
              '${l10n.rightNow}: ${_crowdLabel(l10n, expected)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.insights,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  l10n.expectedCrowding,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _CrowdTimeline(slots: timeSlots, l10n: l10n),
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
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: Text(
                  slot.$2,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: _crowdColor(slot.$1, alpha: 0.45),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 100,
                child: Text(
                  _crowdLabel(l10n, slot.$1),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
