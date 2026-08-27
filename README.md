# Tasbeeh Counter

A beautiful, feature-rich digital tasbeeh (dhikr) counter built with Flutter. Designed for Muslims who want to track their daily dhikr, wazifas, and spiritual goals with an elegant and intuitive interface.

## Features

- **Custom Wazifas** — Create and manage your own dhikr routines with target counts, schedules, and reminders.
- **Quick Dhikr** — Access your favorite dhikrs instantly from the quick-access screen.
- **Smart Scheduling** — Set morning, evening, after-salah, or custom schedules for each wazifa.
- **Progress Tracking** — Visual progress bars, completion badges, and round counters.
- **Daily Reminders** — Notification reminders at your chosen time so you never miss a wazifa.
- **Counter Screen** — Large, haptic-enabled count button with optional volume-key counting.
- **Completion Feedback** — Celebrate with confetti, vibration, and sound effects when you finish.
- **Beautiful UI** — Material 3 design with adaptive app bars, smooth animations, and dark mode support.
- **Multi-language** — Supports English, Arabic, and Urdu.

## Tech Stack

- **Flutter** — Cross-platform UI framework
- **Riverpod** — Reactive state management
- **GoRouter** — Declarative routing
- **Material 3** — Modern Google design system

## Project Structure

```
lib/
  core/          — Theme, localization, notifications, constants
  features/      — One folder per screen (home, counter, settings, etc.)
  models/        — Data classes (Dhikr, DhikrProgress, etc.)
  providers/     — Riverpod state providers
  repositories/  — Data persistence layer
  router/        — GoRouter route configuration
  widgets/       — Reusable widgets (CustomScaffold, CustomButtons)
```

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Custom Widget System

This project uses two core reusable widgets across all screens:

### CustomScaffold
A drop-in replacement for Flutter's `Scaffold` that automatically handles:
- Adaptive app bars (Cupertino for iOS, Material for Android)
- SafeArea wrapping
- Default content padding
- Pull-to-refresh and loading overlays

### CustomButtons
A minimal set of reusable buttons used throughout the app:
- `AppButton.primary` — Main actions
- `AppButton.outlined` — Secondary actions
- `AppButton.text` — Low-emphasis actions
- `AppButton.danger` — Destructive actions
- `AppIconButton` — Inline icon buttons
- `AppFab` — Floating action buttons

## License

MIT
