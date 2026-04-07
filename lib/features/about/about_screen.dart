import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('About SORETRAS'),
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
                      const Text(
                        'About SORETRAS',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'SORETRAS (Soci\u00E9t\u00E9 R\u00E9gionale de Transport du Sahel) '
                    'provides public bus transportation across Sfax and surrounding areas. '
                    'Established to serve the citizens with reliable and affordable transit.',
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
                      const Text('Contact', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ContactRow(
                    icon: Icons.phone_rounded,
                    label: 'Phone',
                    value: '+216 74 240 041',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _ContactRow(
                    icon: Icons.fax_rounded,
                    label: 'Fax',
                    value: '+216 74 240 505',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _ContactRow(
                    icon: Icons.email_rounded,
                    label: 'Email',
                    value: 'contact@soretras.tn',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _ContactRow(
                    icon: Icons.location_on_rounded,
                    label: 'Address',
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
                      const Text('Working Hours', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Buses operate daily from 05:30 to 22:00.\n'
                    'Head office open Monday to Friday, 08:00 - 17:00.',
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
                      const Text('Fares', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Standard fare: 0.50 TND (cash)\n'
                    'Subscription card: 0.35 TND per ride\n'
                    'Student discount available with valid card.',
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
                      const Text('Complaints & Feedback', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'To file a complaint or provide feedback:\n'
                    '1. Call the complaints line: +216 74 240 042\n'
                    '2. Email: reclamations@soretras.tn\n'
                    '3. Visit the head office in person\n\n'
                    'Please provide:\n'
                    '- Bus line number\n'
                    '- Time of incident\n'
                    '- Station name',
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
                      'Powered by SORETRAS Sfax',
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
