# 🚌 Basira - Accessible MaaS for Sfax

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)
![Accessibility](https://img.shields.io/badge/Accessibility-First-green.svg)
![AI](https://img.shields.io/badge/AI-Gemini-orange.svg)

**Basira** is a mobility-as-a-service platform for citizens with disabilities in Sfax, Tunisia. It optimizes the SORETRAS bus network through a synthetic CSV-backed transit pipeline, voice-first assistive design, and AI-powered route planning.

---

## 📌 Project Overview
Basira is built for inclusive transit access by:
- providing voice-first navigation for visually impaired riders,
- exposing haptic and touch feedback for non-visual route confirmation,
- surfacing synthetic bus occupancy and transfer guidance for mobility-impaired passengers.

The current implementation uses a **Synthetic Data Injection layer** sourced from CSV assets, while preserving an architecture ready for a seamless hot-swap to live GTFS or REST APIs.

---

## 🧩 Architecture
### Modular Data Pipeline
Basira is structured as a modular data pipeline with clear separation of concerns:

- **Extract:** `lib/data/services/csv_data_service.dart` reads `assets/data/bus_lines.csv` and `assets/data/stations.csv`.
- **Transform:** parsed CSV rows become typed domain models (`BusLine`, `Station`, `Bus`, `Trip`).
- **Load:** transformed entities are provided to the app through `BusRepository` and Riverpod providers.

### Core Layers
- `lib/main.dart` — app bootstrap, environment loading, CSV initialization, and Riverpod root scope.
- `lib/core/providers.dart` — Riverpod providers, `StateNotifier`s, and persistent settings.
- `lib/data/repositories/bus_repository.dart` — repository abstraction, simulated live bus engine, route search.
- `lib/data/repositories/chat_repository.dart` — Gemini AI prompt management and route intent extraction.
- `lib/features/home/blind_home_screen.dart` — voice-first blind mode interface.

---

## 🔧 Code Audit
### State Management
Basira uses **Riverpod** throughout the app:
- `Provider` for static values and service objects.
- `StateProvider` for instant UI state such as chat history, voice/haptic toggles, and route selection.
- `StateNotifierProvider` for persisted toggles like dark mode and blind mode.
- `FutureProvider.autoDispose` and `.family` for asynchronous data queries.

This results in a scalable state architecture that keeps business logic outside the UI and supports reactive updates.

### Data Layer
The CSV-backed service is the current data source:
- `CsvDataService.initialize()` is called at app startup.
- It validates and converts CSV rows into `BusLine` and `Station` objects.
- The repository layer exposes immutable lists and search/query operations.

`BusRepository` enriches this synthetic data by:
- generating live `Bus` objects with occupancy and schedule metadata,
- simulating GPS movement along Google Directions polylines,
- implementing route-finding for direct and transfer trips,
- exposing trip and station search APIs to the UI.

---

## ♿ Accessibility First
### Voice & Blind Mode
- `BlindHomeScreen` provides a dedicated voice-first mode that replaces the normal home UI when enabled.
- It uses speech recognition (`SttService`) and text-to-speech (`TtsService`) to create a hands-free navigation flow.
- AI-powered intent extraction in `ChatRepository` turns spoken destination requests into route search commands.

### Haptic Feedback
- `HapticService` defines tactile cues for bus approach, arrival, destination proximity, and confirmation.
- The UI triggers these haptic patterns during navigation and voice command interactions.

### Localization and WCAG Support
- Localized strings are provided for Arabic, French, English, and Tunisian dialect.
- The UI uses large tap zones, readable typography, and contrast-aware theming.
- Blind mode and voice controls are explicitly designed to meet WCAG 2.1 principles for accessible mobile apps.

---

## 🚀 Scalability & Engineering Excellence
### Design Patterns
- **Repository pattern** keeps transit data and business rules separate from presentation logic.
- **Provider pattern** with Riverpod simplifies dependency injection and reduces widget-level state complexity.
- **Singleton / shared services** centralize TTS, STT, haptics, directions, and AI access.
- **Domain models** such as `Bus`, `BusLine`, `Station`, `Trip`, and `Section` are used consistently to maintain type safety and clarity.

### ETL Process (Extract → Transform → Load)
1. **Extract** from CSV assets via `CsvDataService`.
2. **Transform** into typed models and compute schedule semantics.
3. **Load** into repositories and surface through Riverpod providers.

This ETL flow is intentionally modular, supporting future replacement with real transit feeds.

---

## 📦 Dependencies
Basira relies on the following key packages:
- `flutter_riverpod` / `riverpod` — state management
- `flutter_tts`, `speech_to_text` — voice assistance
- `dio` — HTTP / API client
- `csv` — CSV parsing
- `google_maps_flutter`, `flutter_map`, `latlong2` — map and geospatial support
- `shared_preferences` — persisted user settings
- `flutter_dotenv` — environment configuration

---

## 🚀 Running the App
### Prerequisites
- Flutter SDK compatible with Dart `^3.11.4`
- Device/emulator for Android or iOS
- `.env` with API credentials for Gemini / Google if AI or directions are enabled

### Commands
```bash
flutter pub get
flutter run
```

### Notes
- `lib/core/services/directions_service.dart` currently contains a placeholder Google Maps API key.
- `lib/core/constants/api_keys.dart` is used by Gemini AI integration.

---

## 🔮 Future Roadmap
Recommended improvements for production-grade deployment:
- replace CSV injection with live GTFS or REST transit feeds,
- add robust unit and widget tests for providers and repository logic,
- secure external API keys and remove hard-coded placeholders,
- add fallback behavior for TTS/STT failures,
- integrate real occupancy/crowd sensing and transport alerts.

---

## 📁 Key Files
- `lib/main.dart`
- `lib/core/providers.dart`
- `lib/data/services/csv_data_service.dart`
- `lib/data/repositories/bus_repository.dart`
- `lib/data/repositories/chat_repository.dart`
- `lib/features/home/blind_home_screen.dart`
- `lib/core/services/tts_service.dart`
- `lib/core/services/stt_service.dart`
- `lib/core/services/haptic_service.dart`
- `assets/data/bus_lines.csv`

---

## ✅ Summary
Basira is a strong accessibility-first Flutter application that cleanly separates UI, state, and data layers. The current implementation uses a synthetic CSV data injection engine but is architected for a future hot-swap to live GTFS/REST transit sources, while delivering voice-first and haptic-first experiences for users with disabilities.
