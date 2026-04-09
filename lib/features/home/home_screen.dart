import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers.dart';
import '../map/map_screen.dart';
import '../chatbot/chatbot_screen.dart';
import '../settings/settings_screen.dart';
import '../trip/station_picker_screen.dart';
import '../trip/my_trips_screen.dart';
import '../schedule/schedule_screen.dart';
import '../nearby/nearby_stations_screen.dart';
import '../crowd/crowd_patterns_screen.dart';
import '../about/about_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeCode = ref.watch(localeStringProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 28),
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(color: Colors.transparent),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(_settingsRoute(context)),
            icon: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.white.withOpacity(0.1),
                  child: Icon(Icons.settings_outlined, color: AppColors.primaryLight, size: 20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                
                // --- Modern Hero Banner ---
                _buildModernHero(context, l10n, localeCode),

                const SizedBox(height: 32),

                // --- Section Title ---
                Text(
                  l10n.ourServices,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                
                const SizedBox(height: 16),

                // --- Modern Bento Grid ---
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                  children: [
                    _buildServiceTile(
                      context,
                      l10n.liveMap,
                      Icons.map_rounded,
                      () => Navigator.of(context).push(_mapRoute(context)),
                      isFullWidth: false,
                    ),
                    _buildServiceTile(
                      context,
                      l10n.planTrip,
                      Icons.bolt_rounded,
                      () => Navigator.of(context).push(_stationPickerRoute(context)),
                      isAccent: true,
                    ),
                    _buildServiceTile(
                      context,
                      l10n.busSchedules,
                      Icons.calendar_today_rounded,
                      () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScheduleScreen())),
                    ),
                    _buildServiceTile(
                      context,
                      l10n.nearbyStations,
                      Icons.location_on_rounded,
                      () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NearbyStationsScreen())),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // --- Horizontal/Secondary Services ---
                _buildWideServiceTile(
                  context,
                  l10n.chatbot,
                  Icons.chat_bubble_outline_rounded,
                  () => Navigator.of(context).push(_chatbotRoute(context)),
                ),
                
                _buildWideServiceTile(
                  context,
                  l10n.myTrips,
                  Icons.auto_awesome_motion_rounded,
                  () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyTripsScreen())),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHero(BuildContext context, AppLocalizations l10n, String localeCode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: -10,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(Icons.cloud_outlined, size: 120, color: Colors.white.withOpacity(0.1)),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.welcomeText,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.welcomeSubtitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
              Hero(
                tag: 'app_icon',
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Image.asset('assets/icons/icon.png', width: 48, height: 48, errorBuilder: (_, __, ___) => const Icon(Icons.directions_bus, color: Colors.white, size: 40)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isAccent = false,
    bool isFullWidth = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Material(
            color: isAccent 
                ? AppColors.primary.withOpacity(0.9)
                : (isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.8)),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onTap();
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 42,
                      color: isAccent ? Colors.white : AppColors.primaryLight,
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: isAccent ? Colors.white : (isDark ? Colors.white : AppColors.textPrimary),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideServiceTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
              blurRadius: 25,
              offset: const Offset(0, 10),
              spreadRadius: -5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Material(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7),
              child: InkWell(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(icon, color: AppColors.primaryLight, size: 26),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right_rounded, size: 24, color: AppColors.primaryLight.withOpacity(0.5)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Routes Identiques ---
  static Route<void> _mapRoute(BuildContext context) =>
      PageRouteBuilder(pageBuilder: (_, __, ___) => const MapScreen());

  static Route<void> _stationPickerRoute(BuildContext context) =>
      PageRouteBuilder(pageBuilder: (_, __, ___) => const StationPickerScreen());

  static Route<void> _chatbotRoute(BuildContext context) =>
      PageRouteBuilder(pageBuilder: (_, __, ___) => const ChatbotScreen());

  static Route<void> _settingsRoute(BuildContext context) =>
      PageRouteBuilder(pageBuilder: (_, __, ___) => const SettingsScreen());
}