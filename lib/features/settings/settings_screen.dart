import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
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
      _showErrorSnackBar('Could not open review');
    }
  }

  Future<void> _checkForUpdate() async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      } else {
        _showInfoSnackBar('You are on the latest version');
      }
    } catch (e) {
      _showErrorSnackBar('Could not check for updates');
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
      final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      await ref.read(settingsProvider.notifier).updateDefaultReminderTime(timeStr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Appearance
          _buildSectionHeader(context, 'Appearance'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: Text(_getThemeLabel(settings.themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemePicker(context),
          ),

          // Counting
          _buildSectionHeader(context, 'Counting'),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up),
            title: const Text('Volume Key Counting'),
            subtitle: const Text('Use volume buttons to count'),
            value: settings.volumeKeyCounting,
            onChanged: (value) => ref.read(settingsProvider.notifier).updateVolumeKeyCounting(value),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: const Text('Counting Vibration'),
            value: settings.countingVibration,
            onChanged: (value) => ref.read(settingsProvider.notifier).updateCountingVibration(value),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up),
            title: const Text('Counting Sound'),
            value: settings.countingSound,
            onChanged: (value) => ref.read(settingsProvider.notifier).updateCountingSound(value),
          ),

          // Completion
          _buildSectionHeader(context, 'Completion'),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: const Text('Completion Vibration'),
            value: settings.completionVibration,
            onChanged: (value) => ref.read(settingsProvider.notifier).updateCompletionVibration(value),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.celebration),
            title: const Text('Completion Sound'),
            value: settings.completionSound,
            onChanged: (value) => ref.read(settingsProvider.notifier).updateCompletionSound(value),
          ),

          // Notifications
          _buildSectionHeader(context, 'Notifications'),
          ListTile(
            leading: Icon(
              _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
              color: _notificationsEnabled ? theme.colorScheme.primary : theme.colorScheme.error,
            ),
            title: const Text('Notification Permission'),
            subtitle: Text(_notificationsEnabled ? 'Granted' : 'Not granted'),
            trailing: !_notificationsEnabled
                ? TextButton(
                    onPressed: _requestNotificationPermission,
                    child: const Text('Enable'),
                  )
                : null,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.alarm),
            title: const Text('Reminder Notifications'),
            subtitle: const Text('Receive daily reminders'),
            value: settings.reminderNotifications,
            onChanged: (value) => ref.read(settingsProvider.notifier).updateReminderNotifications(value),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Default Reminder Time'),
            subtitle: Text(settings.defaultReminderTime),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showReminderTimePicker,
          ),

          // Language
          _buildSectionHeader(context, 'Language'),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Text(_getLanguageLabel(settings.languageCode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguagePicker(context),
          ),

          // App
          _buildSectionHeader(context, 'App'),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('Rate App'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _rateApp,
          ),
          ListTile(
            leading: const Icon(Icons.system_update),
            title: const Text('Check for Updates'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _checkForUpdate,
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openPrivacyPolicy,
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: Text('Version $_appVersion'),
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
    switch (theme) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      default:
        return 'System';
    }
  }

  String _getLanguageLabel(String language) {
    switch (language) {
      case 'en':
        return 'English';
      case 'ar':
        return 'Arabic';
      case 'ur':
        return 'Urdu';
      default:
        return 'System';
    }
  }

  void _showThemePicker(BuildContext context) {
    final settings = ref.read(settingsProvider);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Theme'),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            RadioListTile<String>(
              title: const Text('System'),
              value: 'system',
              groupValue: settings.themeMode,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateTheme(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Light'),
              value: 'light',
              groupValue: settings.themeMode,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateTheme(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Dark'),
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
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Language'),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            RadioListTile<String>(
              title: const Text('System'),
              value: 'system',
              groupValue: settings.languageCode,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateLanguage(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: settings.languageCode,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateLanguage(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Arabic'),
              value: 'ar',
              groupValue: settings.languageCode,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateLanguage(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Urdu'),
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
