import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/l10n_extension.dart';
import '../../models/dhikr.dart';
import '../../models/dhikr_progress.dart';
import '../../models/dhikr_schedule.dart';
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
  DhikrSchedule? _schedule;

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
    final progress = ref.read(progressByIdProvider(widget.dhikrId!));
    if (dhikr != null) {
      final azkar = dhikr.firstAzkar;
      _nameController.text = dhikr.name;
      _arabicController.text = azkar?.arabicText ?? '';
      _transliterationController.text = azkar?.transliteration ?? '';
      _translationController.text = dhikr.translation;
      _targetController.text = (azkar?.targetCount ?? dhikr.totalTargetCount)
          .toString();
      _daysController.text = progress?.numberOfDays?.toString() ?? '';
      _notesController.text = progress?.notes ?? '';
      _repeatEnabled = progress?.repeatEnabled ?? false;
      _reminderEnabled = progress?.reminderEnabled ?? false;
      if (progress?.reminderTime != null) {
        final parts = progress!.reminderTime!.split(':');
        _reminderTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
      _startDate = progress?.startDate;
      _schedule = progress?.scheduleEnum;
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
    final arabicText = _arabicController.text.trim();
    final transliteration = _transliterationController.text.trim();
    final translation = _translationController.text.trim();
    final targetCount = int.tryParse(_targetController.text) ?? 100;
    final numberOfDays = int.tryParse(_daysController.text);
    final reminderTimeStr = _reminderTime != null
        ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
        : null;

    if (_isEditing && widget.dhikrId != null) {
      final repository = ref.read(dhikrRepositoryProvider);
      final existing = ref.read(dhikrByIdProvider(widget.dhikrId!));
      if (existing != null) {
        final baseAzkar = existing.firstAzkar ??
            AzkarItem(
              id: existing.id,
              arabicText: arabicText,
              transliteration: transliteration,
              translation: translation,
              targetCount: targetCount,
            );

        final updatedDhikr = existing.copyWith(
          name: name,
          arabicTitle: name,
          translation: translation,
          azkar: [
            baseAzkar.copyWith(
              arabicText: arabicText,
              transliteration: transliteration,
              translation: translation,
              targetCount: targetCount,
            ),
          ],
        );
        await repository.saveDhikr(updatedDhikr);

        final existingProgress =
            repository.getProgress(widget.dhikrId!) ??
            DhikrProgress(id: widget.dhikrId!);
        var updatedProgress = existingProgress.copyWith(
          repeatEnabled: _repeatEnabled,
          reminderEnabled: _reminderEnabled,
          reminderTime: reminderTimeStr,
          startDate: _startDate,
          numberOfDays: numberOfDays,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          schedule: _schedule?.name,
        );
        if (numberOfDays != null && _startDate != null) {
          updatedProgress = updatedProgress.copyWith(
            endDate: _startDate!.add(Duration(days: numberOfDays)),
          );
        }
        await repository.saveProgress(updatedProgress);

        ref.read(dhikrListNotifierProvider.notifier).refresh();
        ref.read(progressListNotifierProvider.notifier).refresh();
      }
    } else {
      await ref
          .read(dhikrListNotifierProvider.notifier)
          .createCustomDhikr(
            name: name,
            arabicText: arabicText,
            transliteration: transliteration,
            translation: translation,
            targetCount: targetCount,
            repeatEnabled: _repeatEnabled,
            reminderEnabled: _reminderEnabled,
            reminderTime: reminderTimeStr,
            startDate: _startDate,
            numberOfDays: numberOfDays,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            schedule: _schedule?.name,
          );
    }

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? l10n.edit : l10n.createWazifa)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '${l10n.dhikrName} *',
                hintText: l10n.dhikrNameHint,
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.validationRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Arabic Text
            TextFormField(
              controller: _arabicController,
              decoration: InputDecoration(
                labelText: l10n.arabicText,
                hintText: l10n.arabicTextHint,
                prefixIcon: const Icon(Icons.translate),
              ),
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Transliteration
            TextFormField(
              controller: _transliterationController,
              decoration: InputDecoration(
                labelText: l10n.transliteration,
                hintText: l10n.transliterationHint,
                prefixIcon: const Icon(Icons.spellcheck),
              ),
            ),
            const SizedBox(height: 16),

            // Translation
            TextFormField(
              controller: _translationController,
              decoration: InputDecoration(
                labelText: l10n.translation,
                hintText: l10n.translationHint,
                prefixIcon: const Icon(Icons.language),
              ),
            ),
            const SizedBox(height: 16),

            // Target Count
            TextFormField(
              controller: _targetController,
              decoration: InputDecoration(
                labelText: '${l10n.targetCount} *',
                hintText: l10n.targetCountHint,
                prefixIcon: const Icon(Icons.format_list_numbered),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.validationRequired;
                }
                final count = int.tryParse(value);
                if (count == null || count < 1) {
                  return l10n.validationNumber;
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Schedule
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Schedule',
                hintText: 'When should this dhikr be done?',
                prefixIcon: const Icon(Icons.schedule),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<DhikrSchedule?>(
                  value: _schedule,
                  isDense: true,
                  items: [
                    const DropdownMenuItem<DhikrSchedule?>(
                      value: null,
                      child: Text('Any time'),
                    ),
                    ...DhikrSchedule.values.map((s) => DropdownMenuItem(
                          value: s,
                          child: Text('${s.label} — ${s.description}'),
                        )),
                  ],
                  onChanged: (value) => setState(() => _schedule = value),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Repeat Mode
            SwitchListTile(
              title: Text(l10n.repeatMode),
              subtitle: Text(l10n.repeatModeSubtitle),
              value: _repeatEnabled,
              onChanged: (value) => setState(() => _repeatEnabled = value),
              secondary: const Icon(Icons.repeat),
            ),
            const Divider(),

            // Reminder
            SwitchListTile(
              title: Text(l10n.dailyReminder),
              subtitle: Text(l10n.dailyReminderSubtitle),
              value: _reminderEnabled,
              onChanged: (value) => setState(() => _reminderEnabled = value),
              secondary: const Icon(Icons.alarm),
            ),
            if (_reminderEnabled) ...[
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(l10n.reminderTime),
                subtitle: Text(
                  _reminderTime != null
                      ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
                      : l10n.notSet,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickReminderTime,
              ),
            ],
            const Divider(),

            // Duration
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(l10n.startDate),
              subtitle: Text(
                _startDate != null
                    ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                    : l10n.today,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickStartDate,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _daysController,
              decoration: InputDecoration(
                labelText: l10n.numberOfDays,
                hintText: l10n.numberOfDaysHint,
                prefixIcon: const Icon(Icons.timelapse),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.notes,
                hintText: l10n.notesHint,
                prefixIcon: const Icon(Icons.notes),
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
                label: Text(_isEditing ? l10n.update : l10n.create),
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
