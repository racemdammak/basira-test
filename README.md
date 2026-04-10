# Basira
## About
Basira is an inclusive bus companion application designed specifically for the SORETRAS public transport network in Sfax, Tunisia. Built with accessibility at its core, Basira empowers all commuters—including the visually impaired—to navigate the city's bus system with independence and ease. By combining real-time navigation, an intelligent AI assistant, and an intuitive voice-driven interface, Basira ensures that public transport is accessible to everyone.

## Features
- **Real-Time Map Navigation:** Track routes, locate stations, and navigate your journey using interactive maps powered by Google Maps and Flutter Map.
- **Voice Input & Output:** Fully integrated Text-to-Speech (TTS) and Speech-to-Text (STT) functionality provides a continuous, hands-free interaction for visually impaired users.
- **AI Assistant:** Powered by Google Generative AI (Gemini) to answer queries, guide the navigational experience, and provide intelligent transit support.
- **Smart Notifications:** Receive timely location-based alerts and trip updates via robust local notifications.
- **Multi-Language Support:** Comprehensive internationalization (i18n) ensuring the app is accessible in multiple languages.
- **Haptic Feedback:** Tactile responses designed to guide users intuitively without relying exclusively on visual cues.
- **Offline Data Integration:** Reliable access to critical transit schedules and routes via robust offline CSV data parsing.

## Screenshots
<div align="center">
  <img src="screenshots/maps.png" width="220" alt="Map Navigation"/>
  &nbsp;&nbsp;&nbsp;
  <img src="screenshots/chatbot.png" width="220" alt="AI Agent"/>
  &nbsp;&nbsp;&nbsp;
  <img src="screenshots/blind_mode.png" width="220" alt="Blind Mode"/>
</div>

<div align="center">
  <img src="screenshots/nearby_stations.png" width="220" alt="Nearby Stations"/>
  &nbsp;&nbsp;&nbsp;
  <img src="screenshots/select_path.png" width="220" alt="Select Path"/>
  &nbsp;&nbsp;&nbsp;
  <img src="screenshots/schedule.png" width="220" alt="Bus Schedule"/>
</div>

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) `^3.11.4`
- Active Android development setup (Android Studio & SDK configured)
- An Android device or emulator for testing

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/basira.git
   cd basira
   ```

2. **Configure Environment Variables:**
   Create a `.env` file in the root directory (see the [Environment Variables](#environment-variables) section below for required keys).

3. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run the Application:**
   ```bash
   flutter run
   ```

## Project Structure
```text
basira/
├── android/       # Android-specific configuration and build files
├── assets/        # App assets including images, fonts, and offline CSV data
├── lib/           # Main Dart source code
│   ├── data/      # Repositories, API connections, and data providers
│   ├── features/  # Domain-driven feature modules containing UI and logic
│   ├── l10n/      # Localization dictionaries and ARB files
│   └── main.dart  # Application entry point
└── test/          # Unit and widget tests
```

## Environment Variables
Basira requires environment variables to securely integrate sensitive external API keys. Create a `.env` file at the root of the project with the following parameters:

```env
# Google Maps API Key for spatial mapping and location services
MAPS_API_KEY=your_google_maps_api_key_here

# Google Generative AI (Gemini) API Key for the intelligent assistant
GEMINI_API_KEY=your_gemini_api_key_here
```

## Localization
Basira is built for a diverse community and features a solid internationalization setup. We utilize Flutter's `flutter_localizations` package configured via the `l10n.yaml` file. The primary localization assets are managed through `.arb` files located in `lib/l10n/`. The app natively supports dynamically switching between languages (like Arabic, French, and Tunisian Derja) to deliver a localized user experience.
