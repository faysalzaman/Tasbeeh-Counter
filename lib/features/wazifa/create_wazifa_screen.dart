import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/l10n_extension.dart';
import '../../models/dhikr.dart';
import '../../models/dhikr_progress.dart';
import '../../models/dhikr_schedule.dart';
import '../../providers/dhikr_provider.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/custom_scaffold.dart';
import '../../widgets/custom_text_field.dart';
import 'package:iconsax/iconsax.dart';

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
  final List<int> _presetTargets = const [33, 100, 313, 1000];

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
        final baseAzkar =
            existing.firstAzkar ??
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
        await repository.syncReminder(widget.dhikrId!);
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
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return CustomScaffold(
      backgroundColor: theme.colorScheme.surface,
      title: _isEditing ? l10n.edit : l10n.createWazifa,
      padding: EdgeInsets.zero,
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Required: Name
            AppTextField(
              controller: _nameController,
              label: '${l10n.dhikrName} *',
              hint: l10n.dhikrNameHint,
              prefixIcon: Iconsax.text,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.validationRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 28),

            // Required: Target
            Text(
              '${l10n.targetCount} *',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Quick target chips
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _presetTargets.map((target) {
                final isSelected = _targetController.text == target.toString();
                return _TargetChip(
                  target: target,
                  isSelected: isSelected,
                  onSelected: () {
                    setState(() {
                      _targetController.text = target.toString();
                    });
                    HapticFeedback.lightImpact();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Custom target input
            AppTextField.number(
              controller: _targetController,
              hint: l10n.targetCountHint,
              prefixIcon: Iconsax.keyboard,
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

            // Advanced options
            _AdvancedOptionsCard(
              children: [
                // Arabic
                AppTextField(
                  controller: _arabicController,
                  label: l10n.arabicText,
                  hint: l10n.arabicTextHint,
                  prefixIcon: Iconsax.translate,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Transliteration
                AppTextField(
                  controller: _transliterationController,
                  label: l10n.transliteration,
                  hint: l10n.transliterationHint,
                  prefixIcon: Iconsax.textalign_left,
                ),
                const SizedBox(height: 16),

                // Translation
                AppTextField(
                  controller: _translationController,
                  label: l10n.translation,
                  hint: l10n.translationHint,
                  prefixIcon: Iconsax.language_square,
                ),
                const SizedBox(height: 16),

                // Schedule
                DropdownButtonFormField<DhikrSchedule?>(
                  initialValue: _schedule,
                  decoration: InputDecoration(
                    labelText: l10n.scheduleLabel,
                    prefixIcon: const Icon(Iconsax.clock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  items: [
                    DropdownMenuItem<DhikrSchedule?>(
                      value: null,
                      child: Text(l10n.anyTime),
                    ),
                    ...DhikrSchedule.values.map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text('${s.label} — ${s.description}'),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _schedule = value),
                ),
                const SizedBox(height: 16),

                // Repeat toggle
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.repeatMode),
                  subtitle: Text(l10n.repeatModeSubtitle),
                  value: _repeatEnabled,
                  onChanged: (value) => setState(() => _repeatEnabled = value),
                  secondary: const Icon(Iconsax.repeat),
                ),
                const Divider(height: 24),

                // Reminder toggle
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.dailyReminder),
                  subtitle: Text(l10n.dailyReminderSubtitle),
                  value: _reminderEnabled,
                  onChanged: (value) =>
                      setState(() => _reminderEnabled = value),
                  secondary: const Icon(Iconsax.alarm),
                ),
                if (_reminderEnabled) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Iconsax.clock),
                    title: Text(l10n.reminderTime),
                    subtitle: Text(
                      _reminderTime != null
                          ? _reminderTime!.format(context)
                          : l10n.notSet,
                    ),
                    trailing: const Icon(Iconsax.arrow_right_3),
                    onTap: _pickReminderTime,
                  ),
                ],
                const Divider(height: 24),

                // Start date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Iconsax.calendar),
                  title: Text(l10n.startDate),
                  subtitle: Text(
                    _startDate != null
                        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                        : l10n.today,
                  ),
                  trailing: const Icon(Iconsax.arrow_right_3),
                  onTap: _pickStartDate,
                ),
                const SizedBox(height: 8),

                // Number of days
                AppTextField.number(
                  controller: _daysController,
                  label: l10n.numberOfDays,
                  hint: l10n.numberOfDaysHint,
                  prefixIcon: Iconsax.timer,
                ),
                const SizedBox(height: 16),

                // Notes
                AppTextField.multiline(
                  controller: _notesController,
                  label: l10n.notes,
                  hint: l10n.notesHint,
                  prefixIcon: Iconsax.note_text,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Main CTA Button
            AppButton.primary(
              icon: _isEditing ? Iconsax.tick_circle : Iconsax.save_2,
              label: _isEditing ? l10n.update : l10n.create,
              isExpanded: true,
              height: 56,
              onPressed: _saveWazifa,
            ),
            const SizedBox(height: 24),
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

/// A large, tappable chip for quick target selection.
class _TargetChip extends StatelessWidget {
  final int target;
  final bool isSelected;
  final VoidCallback onSelected;

  const _TargetChip({
    required this.target,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;
    final fgColor = isSelected
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurfaceVariant;

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onSelected,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Text(
            '$target',
            style: theme.textTheme.titleMedium?.copyWith(
              color: fgColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// A card that wraps the advanced options in a collapsed ExpansionTile.
class _AdvancedOptionsCard extends StatelessWidget {
  final List<Widget> children;

  const _AdvancedOptionsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            l10n.moreOptions,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            l10n.moreOptionsSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          leading: Icon(Iconsax.setting_2, color: theme.colorScheme.primary),
          children: children,
        ),
      ),
    );
  }
}
