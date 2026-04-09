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
    final darkMode = ref.watch(darkModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.settings),
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
                  _SectionHeader(
                    icon: Icons.language_rounded,
                    title: l10n.language,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _langChip(l10n.english, 'en', currentLocale, ref, isDark),
                      _langChip(l10n.arabic, 'ar', currentLocale, ref, isDark),
                      _langChip(l10n.french, 'fr', currentLocale, ref, isDark),
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
                  _SectionHeader(
                    icon: Icons.record_voice_over_rounded,
                    title: l10n.voiceSettings,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: Text(l10n.enableVoiceAlerts),
                    value: voiceEnabled,
                    activeColor: AppColors.primary,
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _IconCircle(icon: Icons.vibration_rounded),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      l10n.enableHaptics,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Switch(
                    value: hapticsEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (v) {
                      ref.read(hapticsEnabledProvider.notifier).state = v;
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Dark Mode
          Card(
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              secondary: _IconCircle(icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
              title: Text(l10n.darkMode),
              subtitle: Text(l10n.darkModeSubtitle),
              activeColor: AppColors.primary,
              value: darkMode,
              onChanged: (v) {
                ref.read(darkModeProvider.notifier).toggle();
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
                  _SectionHeader(
                    icon: Icons.text_fields_rounded,
                    title: l10n.fontSize,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.text_decrease_outlined, size: 18, color: AppColors.primaryLight),
                      Expanded(
                        child: Slider(
                          min: 0.8,
                          max: 1.4,
                          divisions: 3,
                          value: fontSize,
                          label: _fontSizeLabel(l10n, fontSize),
                          activeColor: AppColors.primary,
                          onChanged: (v) {
                            ref.read(fontSizeProvider.notifier).state = v;
                          },
                        ),
                      ),
                      const Icon(Icons.text_increase_outlined, size: 18, color: AppColors.primaryLight),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.small, style: const TextStyle(fontSize: 12)),
                        Text(l10n.large, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // About SORETRAS
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: _IconCircle(icon: Icons.info_outline_rounded),
              title: Text(l10n.aboutSoretras),
              subtitle: Text(l10n.aboutSubtitle),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.primaryLight),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
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
      String label, String code, Locale current, WidgetRef ref, bool isDark) {
    final isSelected = current.languageCode == code;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      showCheckmark: false,
      selectedColor: AppColors.primary.withOpacity(0.15),
      checkmarkColor: AppColors.primary,
      side: BorderSide(
        color: isSelected ? AppColors.primary : (isDark ? const Color(0xFF3A5040) : AppColors.accent.withOpacity(0.5)),
        width: isSelected ? 1.5 : 1,
      ),
      onSelected: (selected) {
        if (selected) {
          ref.read(localeProvider.notifier).state = Locale(code);
        }
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconCircle(icon: icon),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _IconCircle extends StatelessWidget {
  final IconData icon;

  const _IconCircle({required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A4A30) : const Color(0xFFE8F3E5),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: AppColors.primary),
    );
  }
}
