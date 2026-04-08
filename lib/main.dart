import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'core/providers.dart';
import 'data/services/csv_data_service.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Fallback if .env file is missing or malformed
  }

  await CsvDataService.instance.initialize();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: BasiraApp(),
    ),
  );
}

class BasiraApp extends ConsumerWidget {
  const BasiraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final isDarkMode = ref.watch(darkModeProvider);

    return MaterialApp(
      title: 'Basira',
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('fr'),
        Locale('tun'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return const Locale('en');
        for (var supported in supportedLocales) {
          if (supported.languageCode == locale.languageCode) {
            return supported;
          }
        }
        return const Locale('en');
      },
      theme: _buildThemeData(brightness: Brightness.light),
      darkTheme: _buildThemeData(brightness: Brightness.dark),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(fontSize.clamp(0.8, 1.4)),
          ),
          child: child!,
        );
      },
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildThemeData({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF335836),
        brightness: brightness,
      ),
      useMaterial3: true,
      iconTheme: IconThemeData(
        color: isDark ? const Color(0xFF7CA971) : const Color(0xFF335836),
        size: 24,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1A2E1C) : const Color(0xFF335836),
        foregroundColor: isDark ? const Color(0xFF7CA971) : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: isDark ? const Color(0xFF1E2E20) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        shadowColor: isDark ? const Color(0xFF0A0F0C) : const Color(0xFF335836).withOpacity(0.08),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF253528) : const Color(0xFFF5F0D6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF6B8068) : Colors.grey.shade400,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
      scaffoldBackgroundColor: isDark ? const Color(0xFF121A14) : const Color(0xFFF5F0D6),
    );
  }
}
