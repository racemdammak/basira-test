import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('About SORETRAS'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primary, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'About SORETRAS',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'SORETRAS (Soci\u00E9t\u00E9 R\u00E9gionale de Transport du Sahel) '
                    'provides public bus transportation across Sfax and surrounding areas. '
                    'Established to serve the citizens with reliable and affordable transit.',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Contact info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.phone, color: AppColors.primary, size: 28),
                      SizedBox(width: 12),
                      Text('Contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ContactRow(
                    icon: Icons.phone,
                    label: 'Phone',
                    value: '+216 74 240 041',
                  ),
                  const SizedBox(height: 8),
                  _ContactRow(
                    icon: Icons.fax,
                    label: 'Fax',
                    value: '+216 74 240 505',
                  ),
                  const SizedBox(height: 8),
                  _ContactRow(
                    icon: Icons.email,
                    label: 'Email',
                    value: 'contact@soretras.tn',
                  ),
                  const SizedBox(height: 8),
                  _ContactRow(
                    icon: Icons.location_on,
                    label: 'Address',
                    value: 'Avenue Habib Bourguiba, Sfax',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Working hours
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.access_time, color: AppColors.primary, size: 28),
                      SizedBox(width: 12),
                      Text('Working Hours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Buses operate daily from 05:30 to 22:00.\n'
                    'Head office open Monday to Friday, 08:00 - 17:00.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Fare info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.payments, color: AppColors.primary, size: 28),
                      SizedBox(width: 12),
                      Text('Fares', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Standard fare: 0.50 TND (cash)\n'
                    'Subscription card: 0.35 TND per ride\n'
                    'Student discount available with valid card.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Complaints
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.report_problem, color: AppColors.primary, size: 28),
                      SizedBox(width: 12),
                      Text('Complaints & Feedback', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'To file a complaint or provide feedback:\n'
                    '1. Call the complaints line: +216 74 240 042\n'
                    '2. Email: reclamations@soretras.tn\n'
                    '3. Visit the head office in person\n\n'
                    'Please provide:\n'
                    '- Bus line number\n'
                    '- Time of incident\n'
                    '- Station name',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // App info
          const Center(
            child: Column(
              children: [
                Text(
                  'Basira v1.0.0',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  'Powered by SORETRAS Sfax',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
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

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }
}
