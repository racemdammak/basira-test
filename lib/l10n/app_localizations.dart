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

  /// No description provided for @busSchedules.
  ///
  /// In en, this message translates to:
  /// **'Bus Schedules'**
  String get busSchedules;

  /// No description provided for @nearbyStations.
  ///
  /// In en, this message translates to:
  /// **'Nearby Stations'**
  String get nearbyStations;

  /// No description provided for @crowdPatterns.
  ///
  /// In en, this message translates to:
  /// **'Crowd Patterns'**
  String get crowdPatterns;

  /// No description provided for @aboutSoretras.
  ///
  /// In en, this message translates to:
  /// **'About SORETRAS'**
  String get aboutSoretras;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Contact, fares & complaints'**
  String get aboutSubtitle;

  /// No description provided for @welcomeText.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeText;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your smart Sfax bus companion'**
  String get welcomeSubtitle;

  /// No description provided for @ourServices.
  ///
  /// In en, this message translates to:
  /// **'Our Services'**
  String get ourServices;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet\nStar a route to save it here'**
  String get noFavoritesYet;

  /// No description provided for @noTripHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No trip history yet\nYour recent trips will appear here'**
  String get noTripHistoryYet;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @suggestedDestinations.
  ///
  /// In en, this message translates to:
  /// **'Suggested destinations from'**
  String get suggestedDestinations;

  /// No description provided for @suggestedOrigins.
  ///
  /// In en, this message translates to:
  /// **'Suggested origins to'**
  String get suggestedOrigins;

  /// No description provided for @allStations.
  ///
  /// In en, this message translates to:
  /// **'All stations'**
  String get allStations;

  /// No description provided for @typeToSearch.
  ///
  /// In en, this message translates to:
  /// **'Type to search...'**
  String get typeToSearch;

  /// No description provided for @liveTracking.
  ///
  /// In en, this message translates to:
  /// **'Live Tracking'**
  String get liveTracking;

  /// No description provided for @reportDelay.
  ///
  /// In en, this message translates to:
  /// **'Report Delay'**
  String get reportDelay;

  /// No description provided for @howLateIsBus.
  ///
  /// In en, this message translates to:
  /// **'How late is the bus?'**
  String get howLateIsBus;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @shareRoute.
  ///
  /// In en, this message translates to:
  /// **'Share route'**
  String get shareRoute;

  /// No description provided for @routeCopied.
  ///
  /// In en, this message translates to:
  /// **'Route copied to clipboard!'**
  String get routeCopied;

  /// No description provided for @delayReported.
  ///
  /// In en, this message translates to:
  /// **'Delay reported. Thank you!'**
  String get delayReported;

  /// No description provided for @onBus.
  ///
  /// In en, this message translates to:
  /// **'On bus'**
  String get onBus;

  /// No description provided for @waitingForBus.
  ///
  /// In en, this message translates to:
  /// **'Waiting for bus...'**
  String get waitingForBus;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @workingHours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get workingHours;

  /// No description provided for @fares.
  ///
  /// In en, this message translates to:
  /// **'Fares'**
  String get fares;

  /// No description provided for @complaintsFeedback.
  ///
  /// In en, this message translates to:
  /// **'Complaints & Feedback'**
  String get complaintsFeedback;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @fax.
  ///
  /// In en, this message translates to:
  /// **'Fax'**
  String get fax;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @standardFare.
  ///
  /// In en, this message translates to:
  /// **'Standard fare'**
  String get standardFare;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get go;

  /// No description provided for @nextDepartures.
  ///
  /// In en, this message translates to:
  /// **'Next Departures'**
  String get nextDepartures;

  /// No description provided for @noMoreDepartures.
  ///
  /// In en, this message translates to:
  /// **'No more departures today'**
  String get noMoreDepartures;

  /// No description provided for @stations.
  ///
  /// In en, this message translates to:
  /// **'Stations'**
  String get stations;

  /// No description provided for @veryCrowded.
  ///
  /// In en, this message translates to:
  /// **'Very Crowded'**
  String get veryCrowded;

  /// No description provided for @moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// No description provided for @usuallyAvailable.
  ///
  /// In en, this message translates to:
  /// **'Usually Available'**
  String get usuallyAvailable;

  /// No description provided for @rightNow.
  ///
  /// In en, this message translates to:
  /// **'Right now'**
  String get rightNow;

  /// No description provided for @expectedCrowding.
  ///
  /// In en, this message translates to:
  /// **'Expected crowding throughout the day:'**
  String get expectedCrowding;

  /// No description provided for @line.
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get line;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'SORETRAS (Société Régionale de Transport du Sahel) provides public bus transportation across Sfax and surrounding areas. Established to serve the citizens with reliable and affordable transit.'**
  String get aboutDescription;

  /// No description provided for @workingHoursDetail.
  ///
  /// In en, this message translates to:
  /// **'Buses operate daily from 05:30 to 22:00.\nHead office open Monday to Friday, 08:00 - 17:00.'**
  String get workingHoursDetail;

  /// No description provided for @faresDetail.
  ///
  /// In en, this message translates to:
  /// **'Standard fare: 0.50 TND (cash)\nSubscription card: 0.35 TND per ride\nStudent discount available with valid card.'**
  String get faresDetail;

  /// No description provided for @complaintsDetail.
  ///
  /// In en, this message translates to:
  /// **'To file a complaint or provide feedback:\n1. Call the complaints line: +216 74 240 042\n2. Email: reclamations@soretras.tn\n3. Visit the head office in person\n\nPlease provide:\n- Bus line number\n- Time of incident\n- Station name'**
  String get complaintsDetail;

  /// No description provided for @noRouteDirect.
  ///
  /// In en, this message translates to:
  /// **'No direct route found.'**
  String get noRouteDirect;

  /// No description provided for @changeNeeded.
  ///
  /// In en, this message translates to:
  /// **'You may need to change buses'**
  String get changeNeeded;

  /// No description provided for @invalidTripData.
  ///
  /// In en, this message translates to:
  /// **'Invalid trip data'**
  String get invalidTripData;

  /// No description provided for @arrivingAt.
  ///
  /// In en, this message translates to:
  /// **'Arriving at'**
  String get arrivingAt;

  /// No description provided for @minToDestination.
  ///
  /// In en, this message translates to:
  /// **'min to destination'**
  String get minToDestination;

  /// No description provided for @tunisian.
  ///
  /// In en, this message translates to:
  /// **'Tunisian'**
  String get tunisian;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark theme'**
  String get darkModeSubtitle;

  /// No description provided for @chatbotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your ethereal assistant for Sfax transit'**
  String get chatbotSubtitle;

  /// No description provided for @stopTalking.
  ///
  /// In en, this message translates to:
  /// **'Stop talking'**
  String get stopTalking;

  /// No description provided for @quickQuestions.
  ///
  /// In en, this message translates to:
  /// **'Quick Questions'**
  String get quickQuestions;

  /// No description provided for @suggestedQuestion1.
  ///
  /// In en, this message translates to:
  /// **'⏰ When is the next bus?'**
  String get suggestedQuestion1;

  /// No description provided for @suggestedQuestion2.
  ///
  /// In en, this message translates to:
  /// **'♿ Which buses have ramps?'**
  String get suggestedQuestion2;

  /// No description provided for @suggestedQuestion3.
  ///
  /// In en, this message translates to:
  /// **'🎫 How much is a ticket?'**
  String get suggestedQuestion3;

  /// No description provided for @suggestedQuestion4.
  ///
  /// In en, this message translates to:
  /// **'📅 Bus lines schedule'**
  String get suggestedQuestion4;

  /// No description provided for @poweredBy.
  ///
  /// In en, this message translates to:
  /// **'Powered by SORETRAS Sfax'**
  String get poweredBy;

  /// No description provided for @enableLocationText.
  ///
  /// In en, this message translates to:
  /// **'Please enable location services in your device settings.'**
  String get enableLocationText;

  /// No description provided for @tapToSelectOrigin.
  ///
  /// In en, this message translates to:
  /// **'📍 Tap the map to select your origin station'**
  String get tapToSelectOrigin;

  /// No description provided for @tapToSelectDest.
  ///
  /// In en, this message translates to:
  /// **'📍 Tap the map to select your destination station'**
  String get tapToSelectDest;

  /// No description provided for @noDirectRoute.
  ///
  /// In en, this message translates to:
  /// **'No direct bus route found.'**
  String get noDirectRoute;

  /// No description provided for @lineLabel.
  ///
  /// In en, this message translates to:
  /// **'Line {number}'**
  String lineLabel(Object number);

  /// No description provided for @stopsLabel.
  ///
  /// In en, this message translates to:
  /// **'{number} stops'**
  String stopsLabel(Object number);

  /// No description provided for @newRoute.
  ///
  /// In en, this message translates to:
  /// **'New Route'**
  String get newRoute;

  /// No description provided for @shareMessage.
  ///
  /// In en, this message translates to:
  /// **'Basira Route: {origin} → {destination}\nBus line: {line}\nCheck live schedules at Basira app!'**
  String shareMessage(Object destination, Object line, Object origin);

  /// No description provided for @everyXMin.
  ///
  /// In en, this message translates to:
  /// **'Every {minutes}min'**
  String everyXMin(Object minutes);

  /// No description provided for @linesLabel.
  ///
  /// In en, this message translates to:
  /// **'Lines: {lines}'**
  String linesLabel(Object lines);

  /// No description provided for @kmAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} km away'**
  String kmAway(Object distance);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(Object days);
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
