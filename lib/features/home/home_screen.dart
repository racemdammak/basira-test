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
        title: Text(l10n.appTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primary,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(_settingsRoute(context));
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16.0, left: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.settings, size: 24, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                // Hero Banner
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 24.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.directions_bus_rounded, size: 56, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        localeCode == 'ar' || localeCode == 'tun' ? 'مرحباً بك' : 'Welcome to Basira',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localeCode == 'ar' || localeCode == 'tun'
                            ? 'رفيقك الذكي في صفاقس'
                            : 'Your smart Sfax bus companion',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                
                // Section Title
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0, left: 4.0, right: 4.0),
                  child: Text(
                    localeCode == 'ar' || localeCode == 'tun' ? 'خدماتنا' : 'Our Services',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                _buildActionCard(
                  context: context,
                  icon: Icons.map_rounded,
                  title: l10n.liveMap,
                  onTap: () {
                    Navigator.of(context).push(_mapRoute(context));
                  },
                ),
                _buildActionCard(
                  context: context,
                  icon: Icons.directions_bus_filled_rounded,
                  title: l10n.planTrip,
                  onTap: () {
                    Navigator.of(context).push(_stationPickerRoute(context));
                  },
                ),
                _buildActionCard(
                  context: context,
                  icon: Icons.chat_bubble_rounded,
                  title: l10n.chatbot,
                  onTap: () {
                    Navigator.of(context).push(_chatbotRoute(context));
                  },
                ),
              ],
            ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          highlightColor: AppColors.primaryLight.withOpacity(0.1),
          splashColor: AppColors.primary.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, size: 30, color: AppColors.primary),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primaryLight),
                ),
              ],
            ),
          ),
        ),
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
