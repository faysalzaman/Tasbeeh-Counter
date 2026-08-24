## Project Overview

Build a polished, modern **Digital Tasbeeh Counter / Dhikr & Wazifa app** for Android and iOS using Flutter.

The application must be **100% local/offline-first**. No account, backend, Firebase, or internet connection should be required for the core functionality.

The app should feel calm, spiritual, responsive, and premium, with beautiful animations and a simple user experience.

## Core Requirements

### 1. Digital Tasbeeh Counter

Create a large, prominent digital counter for counting Dhikr/Tasbeeh.

The user should be able to:

- Tap the main counter area to increment the count.
- Use a prominent circular/button-based counting interaction.
- See smooth and satisfying counting animations.
- See visual feedback whenever the count increases.
- Optionally receive vibration feedback.
- Optionally receive a short counting tone.
- See the current count clearly.
- See the target count and remaining count.
- Automatically detect when the target is completed.

Example:

```text
SubhanAllah

67 / 100

██████████████░░░░░░

33 Remaining

        +1
```

The counter interaction should feel extremely responsive, with no noticeable delay.

### 2. Volume Button Counting

Allow users to count using the device's physical volume keys.

Configuration:

- Volume Up → increment count.
- Volume Down → increment count, if enabled.
- User should be able to enable/disable volume-key counting from Settings.
- Volume-key counting should work while the counter screen is open.
- Normal touch counting must continue working regardless of this setting.

Make sure this behavior does not interfere with normal app navigation.

### 3. Built-in Dhikr / Azkaar

Provide a collection of commonly used Dhikr/Azkaar by default.

Examples may include:

- SubhanAllah
- Alhamdulillah
- Allahu Akbar
- Astaghfirullah
- La ilaha illallah
- SubhanAllahi wa bihamdihi
- Salawat / Durood
- Other commonly used authentic Azkaar

Each default Dhikr should have:

- Name
- Arabic text where appropriate
- Transliteration
- Translation/meaning where appropriate
- Recommended/default target count

Users should be able to select a built-in Dhikr and start counting immediately.

Do not make unsupported religious claims. Content should be carefully reviewed and presented accurately.

### 4. Custom Dhikr / Wazifa

Allow users to create their own Wazifa/Dhikr.

A custom Dhikr should support:

- Dhikr name
- Arabic text, optional
- Transliteration, optional
- Target count
- Number of days
- Reminder time
- Optional notes
- Optional sound/vibration preference

Example:

```text
Dhikr Name:
Astaghfirullah

Target:
100

Duration:
7 Days

Reminder:
9:00 PM
```

Custom Dhikr must be stored locally on the device.

### 5. Dhikr Schedule & Reminder

For a custom Wazifa, users can specify how long they want to perform it and when they want to be reminded.

Store:

- Dhikr ID
- Dhikr name
- Target count
- Current count
- Start date
- End date / number of days
- Reminder time
- Completion status
- Last session date/time
- Created date/time

When the scheduled reminder time is reached, show a **local notification** such as:

> Your Dhikr time has arrived.

If the Dhikr schedule/duration has completed, show an appropriate local notification such as:

> Your Dhikr schedule has been completed.

All notifications must be generated locally without a backend.

Provide notification permission handling where required by the platform.

### 6. Save & Continue Later

Users must be able to leave an unfinished Wazifa without losing progress.

Provide a clear **Save / Continue Later** experience.

Example:

```text
Astaghfirullah

67 / 100

[ Save & Exit ]
[ Reset ]
[ Continue ]
```

When saved:

- Preserve the current count.
- Preserve the target.
- Preserve the Dhikr/Wazifa information.
- Preserve schedule information.
- Preserve the last updated time.

When the user returns later, they should see a **Continue Wazifa** section and resume exactly where they stopped.

### 7. Reset

Provide a reset option.

When resetting an active Dhikr:

- Ask for confirmation.
- Set current count back to zero.
- Do not accidentally delete the Dhikr itself.
- Keep the saved Dhikr configuration unless the user explicitly deletes it.

Example confirmation:

> Reset this Dhikr's current progress?

Buttons:

```text
Cancel
Reset
```

### 8. Repeat Mode

Add a repeat option.

When repeat mode is enabled:

- After reaching the target, automatically start a new round.
- Maintain a round/session count.
- Provide visual indication that a new round has started.
- Trigger completion feedback before starting the next round.

Example:

```text
SubhanAllah

Round 3

12 / 33
```

Allow the user to enable/disable repeat mode for each Dhikr.

### 9. Completion Experience

When the target is reached, provide an attractive completion animation.

Include:

- Celebration animation
- Visual success state
- Optional vibration
- Optional completion tone
- Completion message
- Round/session update when repeat mode is enabled

The animation should feel elegant and peaceful rather than excessive.

### 10. Haptic Feedback

Provide configurable vibration feedback.

Settings:

- Counting vibration ON/OFF
- Completion vibration ON/OFF
- Reminder vibration controlled by OS notification settings where appropriate

The user should be able to completely disable vibration.

### 11. Sound / Tone Feedback

Provide configurable sounds.

Settings:

- Counting sound ON/OFF
- Completion sound ON/OFF

Use subtle, pleasant sounds.

Do not make sounds disruptive or continuous.

### 12. Light & Dark Theme

Support:

- Light theme
- Dark theme
- System/default theme

The entire app should adapt consistently:

- Backgrounds
- Text
- Cards
- Buttons
- Progress indicators
- Dialogs
- Navigation
- Icons
- Counter screen
- Settings

Persist the selected theme locally.

### 13. Localization

Implement localization from the beginning.

At minimum support:

- English
- Arabic
- Urdu

Structure the app so additional languages can be added later without changing business logic.

All user-facing text must come from localization resources.

Do not hardcode UI strings.

Support RTL layouts correctly for Arabic and Urdu.

### 14. Settings Screen

Create a comprehensive Settings screen.

Include:

**Appearance**
- Theme
  - Light
  - Dark
  - System

**Counting**
- Volume key counting ON/OFF
- Counting vibration ON/OFF
- Counting sound ON/OFF

**Completion**
- Completion vibration ON/OFF
- Completion sound ON/OFF

**Notifications**
- Reminder notifications ON/OFF
- Notification permission status
- Default reminder behavior

**Language**
- English
- Arabic
- Urdu
- System language

**App**
- Rate App
- Check for Updates
- Privacy Policy
- About

All preferences must be stored locally.

### 15. Reminder Notifications Setting

Provide a dedicated reminder notification setting.

Example:

```text
Reminder Notifications
[ ON ]

Default reminder time
9:00 PM
```

Users should be able to enable/disable reminders globally.

Individual Dhikrs should still be able to have their own schedules.

Changing the global reminder setting should not delete existing Dhikr data.

### 16. In-App Review

Implement the platform's native **in-app review** functionality.

Add a controlled "Rate the App" action.

Do not show the review request aggressively.

Trigger the review flow at appropriate moments, such as after meaningful usage.

If the native review API is unavailable, provide a fallback option to open the app's store listing.

### 17. In-App Update

Implement an **in-app update** experience where supported by the platform.

The app should:

- Detect whether a newer version is available.
- Show an update prompt.
- Allow the user to update where the platform supports it.
- Gracefully fall back to opening the store listing if necessary.

Do not force updates unless explicitly configured for a critical version.

### 18. Home Screen

Create a clean dashboard.

Suggested structure:

```text
Good Evening 🌙

Continue Wazifa
┌─────────────────────────────┐
│ Astaghfirullah              │
│ 67 / 100                    │
│ █████████████░░░            │
│ Continue →                  │
└─────────────────────────────┘

Quick Dhikr

[ SubhanAllah ]
[ Alhamdulillah ]
[ Allahu Akbar ]

My Wazifas

[ + Create Wazifa ]
```

The home screen should prioritize quickly continuing an unfinished Dhikr.

### 19. Dhikr Selection Screen

Provide two categories:

**Default Azkaar**

and

**My Wazifas**

Each Dhikr card can display:

- Name
- Arabic
- Target
- Progress
- Schedule/reminder
- Continue button

Allow:

- Start
- Continue
- Edit
- Delete custom Dhikr

Default Dhikrs should not be accidentally deleted.

### 20. Counter Screen

The counter screen should be the main experience.

Include:

- Dhikr name
- Arabic text if available
- Current count
- Target count
- Remaining count
- Circular progress indicator
- Large interactive counter button
- Reset
- Save & Exit
- Repeat toggle/status
- Optional sound/vibration indicators

The main counting interaction should dominate the screen.

Use smooth animation on every count.

### 21. Progress & Completion State

Show:

```text
67 / 100
33 remaining
67%
```

Use an animated circular or radial progress indicator.

When progress reaches 100%:

- Animate the progress indicator.
- Show completion state.
- Play optional completion tone.
- Trigger optional vibration.
- Show completion message.
- Start next round automatically when Repeat is enabled.

### 22. Local Data Storage

Everything must work offline.

Persist locally:

- Default settings/preferences
- Custom Dhikrs
- Current counts
- Saved/unfinished sessions
- Wazifa schedules
- Reminder configurations
- Completion history if implemented
- Theme
- Language
- Sound settings
- Vibration settings
- Volume-key setting

Use a reliable local persistence solution appropriate for Flutter.

The app must remain fully functional after the device loses internet connectivity.

### 23. Data Model

Use clean models.

Example:

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

Session/progress data can be separated when appropriate.

### 24. Recommended Flutter Architecture

Use a maintainable feature-first architecture.

Suggested structure:

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

Separate:

- UI
- state management
- business logic
- repositories
- local storage
- notification scheduling
- audio
- haptics

Do not put business logic directly inside widgets.

### 25. State Management

Use a scalable state-management approach such as **Riverpod**.

State should manage:

- Current Dhikr
- Current count
- Target
- Progress
- Saved sessions
- Repeat mode
- Settings
- Notification configuration
- Theme
- Localization

Avoid unnecessary rebuilds so the counter remains extremely smooth.

### 26. Performance

The counter must feel instant.

Requirements:

- No database/API request when tapping.
- No unnecessary widget rebuilds.
- Animations must remain smooth.
- Counter changes should happen locally in memory first.
- Persist progress appropriately without blocking the UI.
- App should start quickly.

### 27. UX & Visual Design

Design should be:

- Minimal
- Elegant
- Peaceful
- Modern
- Islamic-inspired without being visually overloaded

Avoid excessive ornamentation.

Use:

- Rounded cards
- Soft shadows
- Clean typography
- Large touch targets
- Beautiful progress animation
- Subtle Islamic visual elements
- Strong contrast
- Accessible text sizes

The counter should be usable with one hand.

### 28. Accessibility

Support:

- Large touch targets
- Screen-reader-friendly labels
- Good color contrast
- Dynamic text where practical
- Clear button labels
- Meaningful semantic labels for the counter

### 29. Error Handling

Handle gracefully:

- Notification permission denied
- Notification scheduling failure
- Audio unavailable
- Vibration unavailable
- Invalid custom Dhikr input
- Storage errors
- Update unavailable
- Review unavailable

Never crash because an optional feature is unavailable.

### 30. Privacy

The application should be privacy-friendly.

Because the app is offline-first:

- No account required.
- No personal data required.
- No cloud synchronization required.
- Core Dhikr data stays on the device.

Any analytics or advertising SDK must be isolated from the core functionality and reflected accurately in the privacy policy.

### 31. Development Priorities

Build in this order:

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

### 32. Important Product Principle

The application must remain useful **without internet access**.

Do not make the user wait for:

- API calls
- Cloud synchronization
- Authentication
- Server responses

The core action should always be:

**Open app → choose Dhikr → tap → count.**

### Final Goal

Create a production-quality **offline Digital Tasbeeh / Dhikr / Wazifa application** that feels significantly more polished than a basic counter.

The app should combine:

**Tasbeeh Counter + Custom Wazifa + Saved Progress + Repeat Mode + Dhikr Reminders + Local Notifications + Haptic/Audio Feedback + Volume-Key Counting + Light/Dark Themes + English/Arabic/Urdu Localization + In-App Review + In-App Update**

while keeping the architecture clean, scalable, performant, and maintainable.

the riverpod state management will be used. 

and for routing , the go router will be used. 