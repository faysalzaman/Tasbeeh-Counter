# Tasbeeh Counter — AI Agent Context

## Project Overview

A Flutter-based digital tasbeeh (dhikr) counter app for Muslims. Features include customizable wazifas (dhikr routines), progress tracking, scheduling, reminders, and a beautiful counter interface with haptic/audio feedback.

## Architecture

- **Framework**: Flutter with Material 3
- **State Management**: Riverpod (`flutter_riverpod`)
- **Routing**: GoRouter (`go_router`)
- **Localization**: Built-in Flutter l10n (ARB files)
- **Icons**: Iconsax (`iconsax` package) — NOT Material Icons
- **Backend**: Local persistence (SharedPreferences/Hive) + optional cloud sync

## Directory Structure

```
lib/
  app.dart              — App widget (MaterialApp configuration)
  main.dart             — Entry point
  core/                 — Shared utilities
    constants/
    localization/       — l10nExtension for easy access
    notifications/
    theme/              — AppColors, AppTheme
    volume/
  features/             — One folder per screen
    home/
    counter/
    dhikr_selection/
    dhikr_detail/
    quick_dhikr/
    my_wazifas/
    continue_wazifa/
    create_wazifa/      — Create/edit wazifa form
    settings/
    onboarding/
  models/               — Data classes (Dhikr, DhikrProgress, etc.)
  providers/            — Riverpod providers
  repositories/         — Data access layer
  router/               — GoRouter configuration
  widgets/              — Reusable widgets
    custom_scaffold.dart
    custom_buttons.dart
    custom_text_field.dart
```

## Coding Conventions

### Widgets
- Use `ConsumerWidget` / `ConsumerStatefulWidget` for Riverpod integration.
- Always use `CustomScaffold` instead of raw `Scaffold`.
- Always use `CustomButtons` (`AppButton`, `AppIconButton`, `AppFab`) instead of raw Material buttons.
- Always use `AppTextField` instead of raw `TextFormField` / `TextField`.
- Follow existing file naming: `*_screen.dart` for pages, `widgets/*.dart` for local widgets.

### Icons (CRITICAL)
**This project uses the `iconsax` package exclusively. NEVER use Material `Icons.xxx`.**

- Import: `import 'package:iconsax/iconsax.dart';`
- Use `Iconsax.xxx` everywhere you would normally use `Icons.xxx`.
- Common mappings:
  - `Icons.add` → `Iconsax.add`
  - `Icons.save` → `Iconsax.save_2`
  - `Icons.delete` → `Iconsax.trash`
  - `Icons.edit` → `Iconsax.edit`
  - `Icons.check_circle` → `Iconsax.tick_circle`
  - `Icons.settings` → `Iconsax.setting`
  - `Icons.search` → `Iconsax.search_normal`
  - `Icons.bookmark` → `Iconsax.bookmark`
  - `Icons.fingerprint` → `Iconsax.finger_scan`
  - `Icons.home` → `Iconsax.home`
  - `Icons.close` → `Iconsax.close_circle`
  - `Icons.arrow_back` → `Iconsax.arrow_left_2`
  - `Icons.arrow_forward` → `Iconsax.arrow_right_3`
  - `Icons.calendar` → `Iconsax.calendar`
  - `Icons.clock` → `Iconsax.clock`
  - `Icons.language` → `Iconsax.language_square`
  - `Icons.notifications` → `Iconsax.notification`
  - `Icons.share` → `Iconsax.share`
  - `Icons.star` → `Iconsax.star`
  - `Icons.menu` → `Iconsax.menu`
  - `Icons.more_vert` → `Iconsax.more`
  - `Icons.person` → `Iconsax.user`
  - `Icons.refresh` → `Iconsax.refresh`
  - `Icons.volume_up` → `Iconsax.volume_high`
  - `Icons.flash_on` → `Iconsax.flash`
  - `Icons.play_arrow` → `Iconsax.play`
  - `Icons.restart_alt` → `Iconsax.refresh`
  - `Icons.schedule` → `Iconsax.clock`
  - `Icons.category` → `Iconsax.category`
  - `Icons.flag` → `Iconsax.flag`
  - `Icons.repeat` → `Iconsax.repeat`
  - `Icons.book` → `Iconsax.book`
  - `Icons.info` → `Iconsax.info_circle`
  - `Icons.warning` → `Iconsax.warning_2`
  - `Icons.error` → `Iconsax.danger`
  - `Icons.check` → `Iconsax.tick_circle`
  - `Icons.access_time` → `Iconsax.clock`
  - `Icons.alarm` → `Iconsax.alarm`
  - `Icons.celebration` → `Iconsax.heart_tick`

### Custom Scaffold (`lib/widgets/custom_scaffold.dart`)
Drop-in replacement for `Scaffold`:
- Automatically provides adaptive app bars (iOS/Android).
- Wraps body in `SafeArea`.
- Default padding is `EdgeInsets.all(16)`; set to `EdgeInsets.zero` for scrollable/list screens.
- Use `title` for simple text, `titleWidget` for custom widgets.
- Use `showAppBar: false` for screens with custom headers (e.g., `SliverAppBar`).

### Custom Buttons (`lib/widgets/custom_buttons.dart`)
Never use raw `FilledButton`, `OutlinedButton`, `TextButton`, `IconButton`, or `FloatingActionButton` directly.

| Widget | Usage |
|--------|-------|
| `AppButton.primary(...)` | Main CTAs (Save, Create, Start, Continue) |
| `AppButton.outlined(...)` | Secondary actions (Cancel, Reset) |
| `AppButton.text(...)` | Low-emphasis inline actions (Skip, Cancel in dialogs) |
| `AppButton.danger(...)` | Destructive actions (Delete, Reset Progress) |
| `AppButton.tonal(...)` | Medium-emphasis actions (Enable) |
| `AppIconButton(...)` | Inline icon actions (Edit, Settings) |
| `AppIconButton.outlined(...)` | Bordered icon buttons (Delete with error border) |
| `AppFab(...)` | Floating action buttons |

Example:
```dart
AppButton.primary(
  icon: Iconsax.save_2,
  label: l10n.save,
  isExpanded: true,
  onPressed: _save,
)
```

### Localization
Access translations via extension:
```dart
final l10n = context.l10n;
l10n.myWazifas;
```

### Theming
- Use `Theme.of(context).colorScheme` for colors.
- App-specific colors are in `AppColors` (`core/theme/app_colors.dart`).
- Do not hardcode colors; always pull from the theme.

### State Management Patterns
- Use `ref.watch(provider)` to read reactive state.
- Use `ref.read(provider.notifier).method()` for one-off actions.
- Use `ref.listen(provider, (prev, next) { ... })` for side effects (e.g., confetti).

### Custom Text Fields (`lib/widgets/custom_text_field.dart`)
Never use raw `TextFormField` or `TextField` directly. Always use `AppTextField`.

| Widget | Usage |
|--------|-------|
| `AppTextField(...)` | Standard text input |
| `AppTextField.number(...)` | Number-only input (digits only, numeric keyboard) |
| `AppTextField.multiline(...)` | Multi-line input (notes, descriptions) |

Example:
```dart
AppTextField(
  controller: _nameController,
  label: l10n.dhikrName,
  hint: l10n.dhikrNameHint,
  prefixIcon: Iconsax.text,
  validator: (v) => v?.trim().isEmpty ?? true ? l10n.validationRequired : null,
)

AppTextField.number(
  controller: _targetController,
  label: l10n.targetCount,
  prefixIcon: Iconsax.tag,
)

AppTextField.multiline(
  controller: _notesController,
  label: l10n.notes,
  prefixIcon: Iconsax.note_text,
)
```

### Dialogs & Bottom Sheets
- Dialog actions should use `AppButton.text` for cancel and `AppButton.primary` / `AppButton.danger` for confirm.
- Bottom sheets should use `AppIconButton` for close buttons.

## Rules for AI Agents

1. **Scaffold Rule**: Every screen MUST use `CustomScaffold`. Never use raw `Scaffold`.
2. **Button Rule**: Every button MUST use widgets from `custom_buttons.dart`. Never use raw Material buttons.
3. **TextField Rule**: Every text field MUST use `AppTextField`. Never use raw `TextFormField` or `TextField`.
4. **Icon Rule**: Every icon MUST use `Iconsax.xxx`. Never use `Icons.xxx` from Material.
5. **Padding Rule**: For screens with `ListView`, `CustomScrollView`, or scrollable content, set `padding: EdgeInsets.zero` on `CustomScaffold` and handle padding inside the scrollable widget.
6. **SafeArea Rule**: Do NOT wrap `CustomScaffold` body in an extra `SafeArea`; `CustomScaffold` already handles this. Only use `safeAreaTop: false` / `safeAreaBottom: false` when needed (e.g., for `SliverAppBar`).
7. **Import Rule**: When adding buttons, import `../../widgets/custom_buttons.dart`. When adding text fields, import `../../widgets/custom_text_field.dart`. When adding icons, import `package:iconsax/iconsax.dart`.
8. **Minimal Changes Rule**: Make the smallest possible change to achieve the goal. Do not refactor unrelated code.
9. **Analyzer Rule**: Run `flutter analyze --no-pub <file>` after modifying code to catch issues early.
