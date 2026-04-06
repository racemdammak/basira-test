import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers.dart';
import '../about/about_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final voiceEnabled = ref.watch(voiceAlertsEnabledProvider);
    final hapticsEnabled = ref.watch(hapticsEnabledProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language, color: AppColors.primaryLight),
                      const SizedBox(width: 12),
                      Text(
                        l10n.language,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _langChip(l10n.english, 'en', currentLocale, ref),
                      _langChip(l10n.arabic, 'ar', currentLocale, ref),
                      _langChip(l10n.french, 'fr', currentLocale, ref),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Voice
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.volume_up, color: AppColors.primaryLight),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.voiceSettings,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SwitchListTile(
                    title: Text(l10n.enableVoiceAlerts),
                    value: voiceEnabled,
                    onChanged: (v) {
                      ref.read(voiceAlertsEnabledProvider.notifier).state = v;
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Haptics
          Card(
            child: SwitchListTile(
              title: Text(l10n.enableHaptics),
              value: hapticsEnabled,
              onChanged: (v) {
                ref.read(hapticsEnabledProvider.notifier).state = v;
              },
            ),
          ),

          const SizedBox(height: 12),

          // Font size
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.text_fields,
                          color: AppColors.primaryLight),
                      const SizedBox(width: 12),
                      Text(
                        l10n.fontSize,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    min: 0.8,
                    max: 1.4,
                    divisions: 3,
                    value: fontSize,
                    label: _fontSizeLabel(l10n, fontSize),
                    onChanged: (v) {
                      ref.read(fontSizeProvider.notifier).state = v;
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.small),
                      Text(l10n.large),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // About SORETRAS
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: AppColors.primary),
              title: Text(l10n.aboutSoretras),
              subtitle: Text(l10n.aboutSubtitle),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _fontSizeLabel(AppLocalizations l10n, double v) {
    if (v < 0.9) return l10n.small;
    if (v > 1.2) return l10n.large;
    return l10n.medium;
  }

  Widget _langChip(
      String label, String code, Locale current, WidgetRef ref) {
    final isSelected = current.languageCode == code;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          ref.read(localeProvider.notifier).state = Locale(code);
        }
      },
    );
  }
}
