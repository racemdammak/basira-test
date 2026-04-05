import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers.dart';
import '../map/map_screen.dart';
import '../chatbot/chatbot_screen.dart';
import '../settings/settings_screen.dart';
import '../trip/station_picker_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeCode = ref.watch(localeStringProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.appTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(_settingsRoute(context));
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.settings, size: 28),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Icon(Icons.directions_bus, size: 64, color: AppColors.primaryLight),
                      const SizedBox(height: 8),
                      Text(
                        localeCode == 'ar' || localeCode == 'tun' ? 'مرحباً بك' : 'Welcome to Basira',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        localeCode == 'ar' || localeCode == 'tun'
                            ? 'رفيقك الذكي في صفاقس'
                            : 'Your smart Sfax bus companion',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildActionCard(
                context: context,
                icon: Icons.map_outlined,
                title: l10n.liveMap,
                onTap: () {
                  Navigator.of(context).push(_mapRoute(context));
                },
              ),
              _buildActionCard(
                context: context,
                icon: Icons.directions_bus_filled,
                title: l10n.planTrip,
                onTap: () {
                  Navigator.of(context).push(_stationPickerRoute(context));
                },
              ),
              _buildActionCard(
                context: context,
                icon: Icons.chat_bubble_outline,
                title: l10n.chatbot,
                onTap: () {
                  Navigator.of(context).push(_chatbotRoute(context));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        minVerticalPadding: 16,
        leading: Icon(icon, size: 32, color: AppColors.primaryLight),
        title: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.primaryLight),
      ),
    );
  }

  static Route<void> _mapRoute(BuildContext context) =>
      PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => const MapScreen());

  static Route<void> _stationPickerRoute(BuildContext context) =>
      PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => const StationPickerScreen());

  static Route<void> _chatbotRoute(BuildContext context) =>
      PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => const ChatbotScreen());

  static Route<void> _settingsRoute(BuildContext context) =>
      PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => const SettingsScreen());
}
