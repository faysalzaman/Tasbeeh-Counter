import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/dhikr.dart';
import '../../providers/dhikr_provider.dart';

class CreateWazifaScreen extends ConsumerStatefulWidget {
  final String? dhikrId;

  const CreateWazifaScreen({super.key, this.dhikrId});

  @override
  ConsumerState<CreateWazifaScreen> createState() => _CreateWazifaScreenState();
}

class _CreateWazifaScreenState extends ConsumerState<CreateWazifaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _arabicController = TextEditingController();
  final _transliterationController = TextEditingController();
  final _translationController = TextEditingController();
  final _targetController = TextEditingController(text: '100');
  final _daysController = TextEditingController();
  final _notesController = TextEditingController();

  bool _repeatEnabled = false;
  bool _reminderEnabled = false;
  TimeOfDay? _reminderTime;
  DateTime? _startDate;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.dhikrId != null) {
      _isEditing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadDhikr();
      });
    }
  }

  void _loadDhikr() {
    final dhikr = ref.read(dhikrByIdProvider(widget.dhikrId!));
    if (dhikr != null) {
      _nameController.text = dhikr.name;
      _arabicController.text = dhikr.arabicText ?? '';
      _transliterationController.text = dhikr.transliteration ?? '';
      _translationController.text = dhikr.translation ?? '';
      _targetController.text = dhikr.targetCount.toString();
      _daysController.text = dhikr.numberOfDays?.toString() ?? '';
      _notesController.text = dhikr.notes ?? '';
      _repeatEnabled = dhikr.repeatEnabled;
      _reminderEnabled = dhikr.reminderEnabled;
      if (dhikr.reminderTime != null) {
        final parts = dhikr.reminderTime!.split(':');
        _reminderTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
      _startDate = dhikr.startDate;
      setState(() {});
    }
  }

  Future<void> _pickReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? const TimeOfDay(hour: 21, minute: 0),
    );
    if (time != null) {
      setState(() => _reminderTime = time);
    }
  }

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _saveWazifa() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final targetCount = int.tryParse(_targetController.text) ?? 100;
    final numberOfDays = int.tryParse(_daysController.text);
    final reminderTimeStr = _reminderTime != null
        ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
        : null;

    if (_isEditing && widget.dhikrId != null) {
      final existing = ref.read(dhikrByIdProvider(widget.dhikrId!));
      if (existing != null) {
        final updated = existing.copyWith(
          name: name,
          arabicText: _arabicController.text.trim().isEmpty ? null : _arabicController.text.trim(),
          transliteration: _transliterationController.text.trim().isEmpty
              ? null
              : _transliterationController.text.trim(),
          translation: _translationController.text.trim().isEmpty
              ? null
              : _translationController.text.trim(),
          targetCount: targetCount,
          repeatEnabled: _repeatEnabled,
          reminderEnabled: _reminderEnabled,
          reminderTime: reminderTimeStr,
          startDate: _startDate,
          numberOfDays: numberOfDays,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
        await ref.read(dhikrListNotifierProvider.notifier).saveDhikr(updated);
      }
    } else {
      await ref.read(dhikrListNotifierProvider.notifier).createCustomDhikr(
            name: name,
            arabicText: _arabicController.text.trim().isEmpty ? null : _arabicController.text.trim(),
            transliteration: _transliterationController.text.trim().isEmpty
                ? null
                : _transliterationController.text.trim(),
            translation: _translationController.text.trim().isEmpty
                ? null
                : _translationController.text.trim(),
            targetCount: targetCount,
            repeatEnabled: _repeatEnabled,
            reminderEnabled: _reminderEnabled,
            reminderTime: reminderTimeStr,
            startDate: _startDate,
            numberOfDays: numberOfDays,
            notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          );
    }

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Wazifa' : 'Create Wazifa'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Dhikr Name *',
                hintText: 'e.g., Astaghfirullah',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Arabic Text
            TextFormField(
              controller: _arabicController,
              decoration: const InputDecoration(
                labelText: 'Arabic Text (Optional)',
                hintText: 'أَسْتَغْفِرُ ٱللَّٰهَ',
                prefixIcon: Icon(Icons.translate),
              ),
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Transliteration
            TextFormField(
              controller: _transliterationController,
              decoration: const InputDecoration(
                labelText: 'Transliteration (Optional)',
                hintText: 'Astaghfirullah',
                prefixIcon: Icon(Icons.spellcheck),
              ),
            ),
            const SizedBox(height: 16),

            // Translation
            TextFormField(
              controller: _translationController,
              decoration: const InputDecoration(
                labelText: 'Translation (Optional)',
                hintText: 'I seek forgiveness from Allah',
                prefixIcon: Icon(Icons.language),
              ),
            ),
            const SizedBox(height: 16),

            // Target Count
            TextFormField(
              controller: _targetController,
              decoration: const InputDecoration(
                labelText: 'Target Count *',
                hintText: 'e.g., 100',
                prefixIcon: Icon(Icons.format_list_numbered),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a target count';
                }
                final count = int.tryParse(value);
                if (count == null || count < 1) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Repeat Mode
            SwitchListTile(
              title: const Text('Repeat Mode'),
              subtitle: const Text('Automatically start a new round after completion'),
              value: _repeatEnabled,
              onChanged: (value) => setState(() => _repeatEnabled = value),
              secondary: const Icon(Icons.repeat),
            ),
            const Divider(),

            // Reminder
            SwitchListTile(
              title: const Text('Daily Reminder'),
              subtitle: const Text('Get notified to perform this Dhikr'),
              value: _reminderEnabled,
              onChanged: (value) => setState(() => _reminderEnabled = value),
              secondary: const Icon(Icons.alarm),
            ),
            if (_reminderEnabled) ...[
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Reminder Time'),
                subtitle: Text(
                  _reminderTime != null
                      ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
                      : 'Not set',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickReminderTime,
              ),
            ],
            const Divider(),

            // Duration
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Start Date (Optional)'),
              subtitle: Text(
                _startDate != null
                    ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                    : 'Today',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickStartDate,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _daysController,
              decoration: const InputDecoration(
                labelText: 'Number of Days (Optional)',
                hintText: 'e.g., 7',
                prefixIcon: Icon(Icons.timelapse),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Any additional notes...',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _saveWazifa,
                icon: const Icon(Icons.save),
                label: Text(_isEditing ? 'Update Wazifa' : 'Create Wazifa'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _arabicController.dispose();
    _transliterationController.dispose();
    _translationController.dispose();
    _targetController.dispose();
    _daysController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
