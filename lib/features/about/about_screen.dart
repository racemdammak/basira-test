import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.aboutSoretras),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // About
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A4A30) : const Color(0xFFE8F3E5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        l10n.aboutSoretras,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.aboutDescription,
                    style: TextStyle(fontSize: 14, height: 1.6, color: isDark ? const Color(0xFFB0C4AE) : AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Contact info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A4A30) : const Color(0xFFE8F3E5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.phone_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Text(l10n.contact, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ContactRow(
                    icon: Icons.phone_rounded,
                    label: l10n.phone,
                    value: '+216 74 240 041',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _ContactRow(
                    icon: Icons.fax_rounded,
                    label: l10n.fax,
                    value: '+216 74 240 505',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _ContactRow(
                    icon: Icons.email_rounded,
                    label: l10n.email,
                    value: 'contact@soretras.tn',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _ContactRow(
                    icon: Icons.location_on_rounded,
                    label: l10n.address,
                    value: 'Avenue Habib Bourguiba, Sfax',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Working hours
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A4A30) : const Color(0xFFE8F3E5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Text(l10n.workingHours, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.workingHoursDetail,
                    style: TextStyle(fontSize: 14, color: isDark ? const Color(0xFFB0C4AE) : AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Fare info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A4A30) : const Color(0xFFE8F3E5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.payments_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Text(l10n.fares, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.faresDetail,
                    style: TextStyle(fontSize: 14, color: isDark ? const Color(0xFFB0C4AE) : AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Complaints
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A4A30) : const Color(0xFFE8F3E5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.feedback_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Text(l10n.complaintsFeedback, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.complaintsDetail,
                    style: TextStyle(fontSize: 14, height: 1.6, color: isDark ? const Color(0xFFB0C4AE) : AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // App info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? const Color(0xFF2A3A2E) : const Color(0xFFE8E0C8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/icons/icon.png', width: 28, height: 28),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basira v1.0.0',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isDark ? const Color(0xFF7CA971) : AppColors.primary,
                      ),
                    ),
                    Text(
                      l10n.poweredBy,
                      style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF6B8068) : AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primaryLight),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF6B8068) : Colors.grey.shade500)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
