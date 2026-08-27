# 📿 Tasbeeh — Digital Dhikr & Wazifa Counter

A polished, modern, **100% offline-first** Digital Tasbeeh Counter and Dhikr/Wazifa app built with **Flutter**. No account, no backend, no internet connection required — just open the app and count.

> Open app → choose Dhikr → tap → count.

---

## ✨ Overview

Tasbeeh is designed to feel **calm, spiritual, responsive, and premium**. It combines a smooth digital counter with custom Wazifa scheduling, local reminders, haptic/audio feedback, and full light/dark theming — all running entirely on-device.

---

## 🚀 Features

### Digital Tasbeeh Counter
- Large, prominent tap-to-count interaction with smooth, satisfying animations
- Optional vibration and counting tone feedback
- Live display of current count, target, remaining count, and progress
- Automatic target-completion detection
- Zero-latency counting — no database or network calls on tap

### Volume Button Counting
- Count using physical Volume Up / Volume Down keys
- Enable/disable from Settings
- Works alongside normal touch counting without breaking navigation

### Built-in Dhikr / Azkaar
Includes commonly used Azkaar by default (SubhanAllah, Alhamdulillah, Allahu Akbar, Astaghfirullah, La ilaha illallah, SubhanAllahi wa bihamdihi, Salawat/Durood, and more), each with:
- Arabic text
- Transliteration
- Translation/meaning
- Recommended default target count

### Custom Dhikr / Wazifa
Create your own Wazifa with:
- Name, Arabic text (optional), transliteration (optional)
- Target count and duration (number of days)
- Reminder time, notes, and sound/vibration preferences
- Fully stored locally on-device

### Dhikr Schedule & Local Reminders
- Local notifications when a scheduled Dhikr time arrives
- Completion notifications when a Wazifa schedule finishes
- All notifications generated locally — no backend required
- Platform-appropriate notification permission handling

### Save & Continue Later
- Save progress at any point without losing count, target, or schedule data
- "Continue Wazifa" section on the Home screen resumes exactly where you left off

### Reset
- Confirmation dialog before resetting progress
- Resets count only — Dhikr configuration is preserved unless explicitly deleted

### Repeat Mode
- Automatically starts a new round after reaching the target
- Tracks round/session count with clear visual indication
- Can be enabled/disabled per Dhikr

### Completion Experience
- Elegant, peaceful celebration animation
- Optional vibration and completion tone
- Completion message and round update

### Feedback & Customization
- Configurable counting and completion **vibration**
- Configurable counting and completion **sound**
- **Light / Dark / System** theme, fully applied across the app
- **Localization**: English, Arabic, Urdu (RTL supported), extensible for more languages

### Settings
Comprehensive settings covering Appearance, Counting, Completion, Notifications, Language, and App info (Rate App, Check for Updates, Privacy Policy, About).

### In-App Review & In-App Update
- Native in-app review flow, triggered non-aggressively after meaningful usage
- In-app update detection with graceful fallback to store listing

### Home Screen
- Quick "Continue Wazifa" card for unfinished sessions
- Quick-access Dhikr shortcuts
- "My Wazifas" list with create action

---

## 🏗️ Architecture

Built with a maintainable, **feature-first** architecture:

```text
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── localization/
│   ├── notifications/
│   ├── audio/
│   ├── haptics/
│   └── storage/
│
├── features/
│   ├── home/
│   ├── counter/
│   ├── dhikr/
│   ├── wazifa/
│   ├── settings/
│   └── onboarding/
│
└── main.dart
```

UI, state management, business logic, repositories, storage, notification scheduling, audio, and haptics are kept cleanly separated — no business logic inside widgets.

### Tech Stack
| Layer | Choice |
|---|---|
| Framework | Flutter |
| State Management | [Riverpod](https://riverpod.dev/) |
| Routing | [go_router](https://pub.dev/packages/go_router) |
| Local Storage | On-device persistence (no backend/Firebase) |
| Notifications | Local scheduled notifications |

---

## 📦 Data Model

```text
Dhikr
- id
- name
- arabicText
- transliteration
- translation
- targetCount
- currentCount
- isDefault
- repeatEnabled
- reminderEnabled
- reminderTime
- startDate
- endDate
- createdAt
- updatedAt
```

Session/progress data is separated from the core Dhikr model where appropriate.

---

## 🔒 Privacy

Tasbeeh is privacy-friendly by design:
- No account or personal data required
- No cloud sync — all Dhikr data stays on the device
- Any optional analytics/ad SDK is isolated from core functionality and disclosed in the Privacy Policy

---

## ⚡ Performance Principles

- No API/database calls on tap — counting happens in memory first
- Persistence happens without blocking the UI
- Minimal widget rebuilds for a consistently smooth counter
- Fast app startup
- Fully functional with no internet connection

---

## ♿ Accessibility

- Large touch targets, usable one-handed
- Screen-reader-friendly and semantic labels
- Strong color contrast in both themes
- Dynamic text sizing where practical

---

## 🗺️ Development Roadmap

1. Project architecture
2. Local storage
3. Default Dhikr data
4. Counter engine
5. Counter animations
6. Save/resume
7. Custom Wazifa creation
8. Reset
9. Repeat mode
10. Haptic feedback
11. Sound feedback
12. Local notifications
13. Reminder settings
14. Theme support
15. Localization
16. Volume-key counting
17. In-app review
18. In-app update
19. Final UI polish
20. Testing and release preparation

---

## 🛠️ Getting Started

```bash
# Clone the repository
git clone <repository-url>
cd tasbeeh

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Requirements
- Flutter SDK (stable channel)
- Android Studio / Xcode for platform builds

---

## 🌐 Localization

All user-facing strings are sourced from localization resources — nothing is hardcoded. Supported out of the box:
- English
- Arabic (RTL)
- Urdu (RTL)

The localization structure is designed to support additional languages without touching business logic.

---

## 🤝 Contributing

Contributions are welcome. Please open an issue to discuss significant changes before submitting a pull request.

---

## 📄 License

Add your chosen license here (e.g., MIT, Apache 2.0).

---

## 🙏 Disclaimer

Dhikr/Azkaar content is provided for convenience and personal practice. Content is reviewed for accuracy, but users are encouraged to verify religious content with a qualified source. The app makes no unsupported religious claims.