import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/l10n_extension.dart';
import '../../core/notifications/notification_service.dart';
import '../../providers/settings_provider.dart';

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
        await inAppReview.openStoreListing(
          appStoreId: AppConstants.appStoreId,
        );
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar(context.l10n.couldNotOpenReview);
    }
  }

  Future<void> _checkForUpdate() async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      } else {
        if (mounted) _showInfoSnackBar(context.l10n.onLatestVersion);
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar(context.l10n.couldNotCheckUpdates);
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse('https://your-website.com/privacy-policy');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          // Appearance
          _buildSectionHeader(context, l10n.appearance),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l10n.theme),
            subtitle: Text(_getThemeLabel(settings.themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemePicker(context),
          ),

          // Counting
          _buildSectionHeader(context, l10n.counting),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up),
            title: Text(l10n.volumeKeyCounting),
            subtitle: Text(l10n.volumeKeyCountingSubtitle),
            value: settings.volumeKeyCounting,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).updateVolumeKeyCounting(value),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: Text(l10n.countingVibration),
            value: settings.countingVibration,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).updateCountingVibration(value),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up),
            title: Text(l10n.countingSound),
            value: settings.countingSound,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).updateCountingSound(value),
          ),

          // Completion
          _buildSectionHeader(context, l10n.completion),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: Text(l10n.completionVibration),
            value: settings.completionVibration,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).updateCompletionVibration(value),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.celebration),
            title: Text(l10n.completionSound),
            value: settings.completionSound,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).updateCompletionSound(value),
          ),

          // Notifications
          _buildSectionHeader(context, l10n.notifications),
          ListTile(
            leading: Icon(
              _notificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: _notificationsEnabled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
            title: Text(l10n.notificationPermission),
            subtitle: Text(_notificationsEnabled ? l10n.granted : l10n.notGranted),
            trailing: !_notificationsEnabled
                ? TextButton(
                    onPressed: _requestNotificationPermission,
                    child: Text(l10n.enable),
                  )
                : null,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.alarm),
            title: Text(l10n.reminderNotifications),
            subtitle: Text(l10n.reminderNotificationsSubtitle),
            value: settings.reminderNotifications,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).updateReminderNotifications(value),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(l10n.defaultReminderTime),
            subtitle: Text(settings.defaultReminderTime),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showReminderTimePicker,
          ),

          // Language
          _buildSectionHeader(context, l10n.language),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(_getLanguageLabel(settings.languageCode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguagePicker(context),
          ),

          // App
          _buildSectionHeader(context, l10n.app),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: Text(l10n.rateApp),
            trailing: const Icon(Icons.chevron_right),
            onTap: _rateApp,
          ),
          ListTile(
            leading: const Icon(Icons.system_update),
            title: Text(l10n.checkForUpdates),
            trailing: const Icon(Icons.chevron_right),
            onTap: _checkForUpdate,
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyPolicy),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openPrivacyPolicy,
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.about),
            subtitle: Text('${l10n.version} $_appVersion'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
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

  void _showThemePicker(BuildContext context) {
    final settings = ref.read(settingsProvider);
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.theme),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            RadioListTile<String>(
              title: Text(l10n.themeSystem),
              value: 'system',
              groupValue: settings.themeMode,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateTheme(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.themeLight),
              value: 'light',
              groupValue: settings.themeMode,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateTheme(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.themeDark),
              value: 'dark',
              groupValue: settings.themeMode,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateTheme(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final settings = ref.read(settingsProvider);
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.language),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            RadioListTile<String>(
              title: Text(l10n.languageSystem),
              value: 'system',
              groupValue: settings.languageCode,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateLanguage(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.languageEnglish),
              value: 'en',
              groupValue: settings.languageCode,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateLanguage(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.languageArabic),
              value: 'ar',
              groupValue: settings.languageCode,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateLanguage(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.languageUrdu),
              value: 'ur',
              groupValue: settings.languageCode,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateLanguage(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
