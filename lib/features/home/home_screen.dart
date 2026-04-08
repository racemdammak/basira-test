import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

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
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
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
            icon: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: const Icon(Icons.settings_outlined, color: AppColors.primary, size: 20),
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
                _buildModernHero(context, localeCode),

                const SizedBox(height: 32),

                // --- Section Title ---
                Text(
                  localeCode == 'ar' ? 'خدماتنا' : 'Services',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                
                const SizedBox(height: 16),

                // --- Modern Bento Grid ---
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
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
                  'My Trips',
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

  Widget _buildModernHero(BuildContext context, String localeCode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localeCode == 'ar' ? 'مرحباً بك' : 'Hello there!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  localeCode == 'ar' ? 'بصيرة صفاقس' : 'Welcome to\nBasira Sfax',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Image.asset('assets/icons/icon.png', width: 50, height: 50),
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isAccent 
                ? AppColors.primary 
                : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isAccent ? Colors.transparent : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
            ),
            boxShadow: isDark ? [] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: 32,
                color: isAccent ? Colors.white : AppColors.primary,
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isAccent ? Colors.white : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ],
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
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.withOpacity(0.5)),
            ],
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