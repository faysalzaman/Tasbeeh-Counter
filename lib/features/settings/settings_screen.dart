import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/l10n_extension.dart';
import '../../core/notifications/notification_service.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/custom_scaffold.dart';
import 'widgets/language_picker_sheet.dart';
import 'widgets/settings_group_card.dart';
import 'widgets/theme_picker_sheet.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
    _checkNotifications();
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = packageInfo.version;
      });
    }
  }

  Future<void> _checkNotifications() async {
    final enabled = await NotificationService().areNotificationsEnabled();
    if (mounted) {
      setState(() {
        _notificationsEnabled = enabled;
      });
    }
  }

  Future<void> _requestNotificationPermission() async {
    final granted = await NotificationService().requestPermission();
    setState(() => _notificationsEnabled = granted);
  }

  Future<void> _rateApp() async {
    try {
      final inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      } else {
        await inAppReview.openStoreListing(appStoreId: AppConstants.appStoreId);
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar(context.l10n.couldNotOpenReview);
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse(
      'https://docs.google.com/document/d/1AqEvC4Eq5Kiva1cQmF5B-l-Yq92vaVTNKQcxKB65J60/edit?usp=sharing',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _showReminderTimePicker() async {
    final settings = ref.read(settingsProvider);
    final parts = settings.defaultReminderTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (time != null) {
      final timeStr =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      await ref
          .read(settingsProvider.notifier)
          .updateDefaultReminderTime(timeStr);
    }
  }

  String _formatTimeString(String rawTime) {
    try {
      final parts = rawTime.split(':');
      final tod = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
      return tod.format(context);
    } catch (_) {
      return rawTime;
    }
  }

  String _getThemeLabel(String theme) {
    final l10n = context.l10n;
    switch (theme) {
      case 'light':
        return l10n.themeLight;
      case 'dark':
        return l10n.themeDark;
      default:
        return l10n.themeSystem;
    }
  }

  String _getLanguageLabel(String language) {
    final l10n = context.l10n;
    switch (language) {
      case 'en':
        return l10n.languageEnglish;
      case 'ar':
        return l10n.languageArabic;
      case 'ur':
        return l10n.languageUrdu;
      default:
        return l10n.languageSystem;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return CustomScaffold(
      backgroundColor: theme.colorScheme.surface,
      title: l10n.settings,
      padding: EdgeInsets.zero,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Appearance
          SettingsGroupCard(
            title: l10n.appearance,
            children: [
              ListTile(
                leading: const Icon(Iconsax.color_swatch),
                title: Text(l10n.theme),
                subtitle: Text(_getThemeLabel(settings.themeMode)),
                trailing: const Icon(Iconsax.arrow_right_3),
                onTap: () => _showPickerBottomSheet(context, const ThemePickerSheet()),
              ),
            ],
          ),

          // Counting Feedback
          SettingsGroupCard(
            title: l10n.counting,
            children: [
              SwitchListTile.adaptive(
                secondary: const Icon(Iconsax.volume_high),
                title: Text(l10n.volumeKeyCounting),
                subtitle: Text(l10n.volumeKeyCountingSubtitle),
                value: settings.volumeKeyCounting,
                onChanged: (value) => ref
                    .read(settingsProvider.notifier)
                    .updateVolumeKeyCounting(value),
              ),
              const Divider(height: 1),
              SwitchListTile.adaptive(
                secondary: const Icon(Iconsax.activity),
                title: Text(l10n.countingVibration),
                value: settings.countingVibration,
                onChanged: (value) => ref
                    .read(settingsProvider.notifier)
                    .updateCountingVibration(value),
              ),
              const Divider(height: 1),
              SwitchListTile.adaptive(
                secondary: const Icon(Iconsax.chart),
                title: Text(l10n.countingSound),
                value: settings.countingSound,
                onChanged: (value) => ref
                    .read(settingsProvider.notifier)
                    .updateCountingSound(value),
              ),
            ],
          ),

          // Completion Feedback
          SettingsGroupCard(
            title: l10n.completion,
            children: [
              SwitchListTile.adaptive(
                secondary: const Icon(Iconsax.activity),
                title: Text(l10n.completionVibration),
                value: settings.completionVibration,
                onChanged: (value) => ref
                    .read(settingsProvider.notifier)
                    .updateCompletionVibration(value),
              ),
              const Divider(height: 1),
              SwitchListTile.adaptive(
                secondary: const Icon(Iconsax.heart_tick),
                title: Text(l10n.completionSound),
                value: settings.completionSound,
                onChanged: (value) => ref
                    .read(settingsProvider.notifier)
                    .updateCompletionSound(value),
              ),
            ],
          ),

          // Notifications
          SettingsGroupCard(
            title: l10n.notifications,
            children: [
              ListTile(
                leading: Icon(
                  _notificationsEnabled
                      ? Iconsax.notification
                      : Iconsax.notification_bing,
                  color: _notificationsEnabled
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
                title: Text(l10n.notificationPermission),
                subtitle: Text(
                  _notificationsEnabled ? l10n.granted : l10n.notGranted,
                ),
                trailing: !_notificationsEnabled
                    ? AppButton.tonal(
                        label: l10n.enable,
                        onPressed: _requestNotificationPermission,
                      )
                    : Icon(
                        Iconsax.tick_circle,
                        color: theme.colorScheme.primary,
                      ),
              ),
              const Divider(height: 1),
              SwitchListTile.adaptive(
                secondary: const Icon(Iconsax.alarm),
                title: Text(l10n.reminderNotifications),
                subtitle: Text(l10n.reminderNotificationsSubtitle),
                value: settings.reminderNotifications,
                onChanged: (value) => ref
                    .read(settingsProvider.notifier)
                    .updateReminderNotifications(value),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Iconsax.clock),
                title: Text(l10n.defaultReminderTime),
                subtitle: Text(_formatTimeString(settings.defaultReminderTime)),
                trailing: const Icon(Iconsax.arrow_right_3),
                onTap: _showReminderTimePicker,
              ),
            ],
          ),

          // Language & Localization
          SettingsGroupCard(
            title: l10n.language,
            children: [
              ListTile(
                leading: const Icon(Iconsax.language_square),
                title: Text(l10n.language),
                subtitle: Text(_getLanguageLabel(settings.languageCode)),
                trailing: const Icon(Iconsax.arrow_right_3),
                onTap: () => _showPickerBottomSheet(context, const LanguagePickerSheet()),
              ),
            ],
          ),

          // Application Info & Links
          SettingsGroupCard(
            title: l10n.app,
            children: [
              ListTile(
                leading: const Icon(Iconsax.star),
                title: Text(l10n.rateApp),
                trailing: const Icon(Iconsax.arrow_right_3),
                onTap: _rateApp,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Iconsax.shield_security),
                title: Text(l10n.privacyPolicy),
                trailing: const Icon(Iconsax.arrow_right_3),
                onTap: _openPrivacyPolicy,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Iconsax.info_circle),
                title: Text(l10n.about),
                subtitle: Text('${l10n.version} $_appVersion'),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showPickerBottomSheet(BuildContext context, Widget sheet) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => sheet,
    );
  }
}
