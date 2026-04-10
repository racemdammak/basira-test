# 🚌 Basira - Empowering Autonomous Mobility in Sfax

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)
![Accessibility](https://img.shields.io/badge/Accessibility-First-green.svg)
![AI](https://img.shields.io/badge/AI-Gemini%20%7C%20Groq-orange.svg)

**Basira** is an accessibility-first public transit platform built for Sfax, Tunisia. It transforms complex, unpredictable bus networks into an autonomous, voice-guided experience specifically engineered for visually, mobility, and cognitively impaired citizens.

---

## 🎯 The Mission
In Sfax, taking the bus is a visual and physical challenge. Basira changes this by combining a highly accurate GPS simulation engine with Generative AI (Gemini/Groq) to provide:
1. **Visually Impaired Users:** Step-by-step narrative routing and proactive haptic/voice alerts before their stop.
2. **Mobility Impaired Users:** Real-time crowd-sourced occupancy data, ensuring they don't wait for a bus they cannot board.
3. **Cognitively Impaired Users:** Proactive AI anomaly detection that warns the user if they miss their transfer.

## 🚀 Key Features
* **Accessibility First Interface:** Fully compatible with screen readers, utilizing custom Text-to-Speech (TTS) and Speech-to-Text (STT) navigation.
* **Proactive AI Guide:** Gemini/Groq powered assistant that understands natural language queries and narrates complex multi-leg journeys.
* **Smart GPS Simulation Engine:** A custom physics engine that maps Mock Sfax buses perfectly onto real-world Google Maps road curves, recalculating ETAs every 3 seconds.
* **Haptic Feedback Routing:** Custom vibration patterns (Approaching, Arrived, Transfer) allow navigation without looking at the screen.
* **Multi-Leg Transfers:** Smart algorithms calculate the fastest routes, including complex transfers across Sfax's radial network.

## 🏗 Architecture
* **Frontend:** Flutter & Dart
* **State Management:** Riverpod (Immutable, scalable state for complex trip legs)
* **Maps:** Google Maps Flutter SDK & Google Directions API
* **AI:** Groq (Llama-3) for real-time STT/TTS processing, Google Gemini for complex route narration.

## 🛠 Installation & Setup

1. **Clone the repository**
   ```bash
   git clone [https://github.com/yourusername/basira.git](https://github.com/yourusername/basira.git)
   cd basira
