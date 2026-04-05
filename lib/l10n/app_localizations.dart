import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_tun.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
    Locale('tun'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Basira'**
  String get appTitle;

  /// No description provided for @planTrip.
  ///
  /// In en, this message translates to:
  /// **'Plan a Trip'**
  String get planTrip;

  /// No description provided for @liveMap.
  ///
  /// In en, this message translates to:
  /// **'Live Map'**
  String get liveMap;

  /// No description provided for @chatbot.
  ///
  /// In en, this message translates to:
  /// **'Chatbot'**
  String get chatbot;

  /// No description provided for @myTrips.
  ///
  /// In en, this message translates to:
  /// **'My Trips'**
  String get myTrips;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @selectOrigin.
  ///
  /// In en, this message translates to:
  /// **'Select Origin'**
  String get selectOrigin;

  /// No description provided for @selectDestination.
  ///
  /// In en, this message translates to:
  /// **'Select Destination'**
  String get selectDestination;

  /// No description provided for @selectStation.
  ///
  /// In en, this message translates to:
  /// **'Select Station'**
  String get selectStation;

  /// No description provided for @searchStation.
  ///
  /// In en, this message translates to:
  /// **'Search for a station...'**
  String get searchStation;

  /// No description provided for @findRoute.
  ///
  /// In en, this message translates to:
  /// **'Find Route'**
  String get findRoute;

  /// No description provided for @nextBus.
  ///
  /// In en, this message translates to:
  /// **'Next Bus'**
  String get nextBus;

  /// No description provided for @busLines.
  ///
  /// In en, this message translates to:
  /// **'Bus Lines'**
  String get busLines;

  /// No description provided for @takeThisBus.
  ///
  /// In en, this message translates to:
  /// **'Take This Bus'**
  String get takeThisBus;

  /// No description provided for @onTheBus.
  ///
  /// In en, this message translates to:
  /// **'I\'m on the Bus'**
  String get onTheBus;

  /// No description provided for @busFull.
  ///
  /// In en, this message translates to:
  /// **'This bus is full! (M3abiya)'**
  String get busFull;

  /// No description provided for @routePlanned.
  ///
  /// In en, this message translates to:
  /// **'Route Planned'**
  String get routePlanned;

  /// No description provided for @noBuses.
  ///
  /// In en, this message translates to:
  /// **'No buses available for this route right now'**
  String get noBuses;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Try again later'**
  String get tryAgainLater;

  /// No description provided for @approaching.
  ///
  /// In en, this message translates to:
  /// **'Approaching'**
  String get approaching;

  /// No description provided for @arrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get arrived;

  /// No description provided for @destinationSoon.
  ///
  /// In en, this message translates to:
  /// **'Your destination is near'**
  String get destinationSoon;

  /// No description provided for @youHaveArrived.
  ///
  /// In en, this message translates to:
  /// **'You have arrived!'**
  String get youHaveArrived;

  /// No description provided for @startTrip.
  ///
  /// In en, this message translates to:
  /// **'Start Trip'**
  String get startTrip;

  /// No description provided for @endTrip.
  ///
  /// In en, this message translates to:
  /// **'End Trip'**
  String get endTrip;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @crowded.
  ///
  /// In en, this message translates to:
  /// **'Crowded'**
  String get crowded;

  /// No description provided for @full.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get full;

  /// No description provided for @rampAvailable.
  ///
  /// In en, this message translates to:
  /// **'Ramp Available'**
  String get rampAvailable;

  /// No description provided for @lowFloor.
  ///
  /// In en, this message translates to:
  /// **'Low Floor'**
  String get lowFloor;

  /// No description provided for @noAccessibility.
  ///
  /// In en, this message translates to:
  /// **'No Accessibility Feature'**
  String get noAccessibility;

  /// No description provided for @capacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacity;

  /// No description provided for @estimatedTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated Time'**
  String get estimatedTime;

  /// No description provided for @direction.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get direction;

  /// No description provided for @chatPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Ask about bus schedules...'**
  String get chatPlaceholder;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// No description provided for @voiceInput.
  ///
  /// In en, this message translates to:
  /// **'Voice Input'**
  String get voiceInput;

  /// No description provided for @voiceOutput.
  ///
  /// In en, this message translates to:
  /// **'Read responses aloud'**
  String get voiceOutput;

  /// No description provided for @suggestedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Suggested Questions'**
  String get suggestedQuestions;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @tunisian.
  ///
  /// In en, this message translates to:
  /// **'تونسي'**
  String get tunisian;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @voiceSettings.
  ///
  /// In en, this message translates to:
  /// **'Voice Settings'**
  String get voiceSettings;

  /// No description provided for @enableVoiceAlerts.
  ///
  /// In en, this message translates to:
  /// **'Enable Voice Alerts'**
  String get enableVoiceAlerts;

  /// No description provided for @enableHaptics.
  ///
  /// In en, this message translates to:
  /// **'Enable Vibrations'**
  String get enableHaptics;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get small;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get large;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchHint;

  /// No description provided for @busApproaching.
  ///
  /// In en, this message translates to:
  /// **'Your bus is approaching!'**
  String get busApproaching;

  /// No description provided for @busArrived.
  ///
  /// In en, this message translates to:
  /// **'Your bus has arrived!'**
  String get busArrived;

  /// No description provided for @destinationSoonText.
  ///
  /// In en, this message translates to:
  /// **'You will arrive at your destination in 5 minutes. Get ready!'**
  String get destinationSoonText;

  /// No description provided for @destinationArrivedText.
  ///
  /// In en, this message translates to:
  /// **'You have arrived at your destination. Thank you for using Basira!'**
  String get destinationArrivedText;

  /// No description provided for @m3abiya.
  ///
  /// In en, this message translates to:
  /// **'M3abiya! (This bus is full)'**
  String get m3abiya;

  /// No description provided for @crowdReportSent.
  ///
  /// In en, this message translates to:
  /// **'Crowd report sent. Thank you!'**
  String get crowdReportSent;

  /// No description provided for @noRouteFound.
  ///
  /// In en, this message translates to:
  /// **'No direct route found.'**
  String get noRouteFound;

  /// No description provided for @changeRequired.
  ///
  /// In en, this message translates to:
  /// **'You may need to change buses'**
  String get changeRequired;

  /// No description provided for @eta.
  ///
  /// In en, this message translates to:
  /// **'ETA'**
  String get eta;

  /// No description provided for @departures.
  ///
  /// In en, this message translates to:
  /// **'Departures'**
  String get departures;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr', 'tun'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'tun':
      return AppLocalizationsTun();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
