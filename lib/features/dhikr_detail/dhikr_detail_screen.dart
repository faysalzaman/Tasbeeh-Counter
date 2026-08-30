import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/localization/l10n_extension.dart';
import '../../models/dhikr.dart';
import '../../providers/dhikr_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/custom_scaffold.dart';
import 'package:iconsax/iconsax.dart';

class DhikrDetailScreen extends ConsumerWidget {
  final String dhikrId;

  const DhikrDetailScreen({super.key, required this.dhikrId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dhikr = ref.watch(dhikrByIdProvider(dhikrId));
    final progress = ref.watch(progressByIdProvider(dhikrId));
    final theme = Theme.of(context);
    final l10n = context.l10n;

    if (dhikr == null) {
      return CustomScaffold(
        showAppBar: false,
        padding: EdgeInsets.zero,
        body: Center(
          child: Text(l10n.noCustomWazifas, style: theme.textTheme.titleMedium),
        ),
      );
    }

    final targetCount = dhikr.totalTargetCount;
    final currentCount = progress?.currentCount ?? 0;
    final isInProgress = currentCount > 0 && currentCount < targetCount;
    final isCompleted = progress?.isCompleted ?? false;

    return CustomScaffold(
      backgroundColor: theme.colorScheme.surface,
      showAppBar: false,
      padding: EdgeInsets.zero,
      safeAreaTop: false,
      safeAreaBottom: false,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Dynamic Header App Bar
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 2,
            backgroundColor: theme.colorScheme.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              AppIconButton(
                icon: Iconsax.bookmark,
                onPressed: null,
                tooltip: 'Save',
                color: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
              ),
              AppIconButton(
                icon: Iconsax.share,
                onPressed: null,
                tooltip: 'Share',
                color: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(
                left: 16,
                bottom: 16,
                right: 16,
              ),
              title: LayoutBuilder(
                builder: (context, constraints) {
                  final isCollapsed =
                      constraints.maxHeight <=
                      kToolbarHeight + MediaQuery.of(context).padding.top + 10;
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isCollapsed ? 1.0 : 0.0,
                    child: Text(
                      dhikr.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.08,
                      child: Icon(
                        Iconsax.star1,
                        size: 280,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          dhikr.name,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (dhikr.translation.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            dhikr.translation,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary.withValues(
                                alpha: 0.85,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderSection(dhikr: dhikr),
                  const SizedBox(height: 28),
                  if (dhikr.azkar.isNotEmpty) ...[
                    _SectionHeader(
                      title: l10n.azkarRecitations,
                      count: dhikr.azkar.length,
                      icon: Iconsax.book,
                    ),
                    const SizedBox(height: 12),
                    ..._buildAzkar(context, dhikr),
                    const SizedBox(height: 28),
                  ],
                  if (dhikr.references.isNotEmpty) ...[
                    _SectionHeader(
                      title: l10n.references,
                      count: dhikr.references.length,
                      icon: Iconsax.verify,
                    ),
                    const SizedBox(height: 12),
                    ..._buildReferences(context, dhikr),
                    const SizedBox(height: 28),
                  ],
                  if (dhikr.benefits.isNotEmpty) ...[
                    _SectionHeader(
                      title: l10n.benefitsAndVirtues,
                      icon: Iconsax.star,
                    ),
                    const SizedBox(height: 12),
                    _buildBenefits(context, dhikr),
                    const SizedBox(height: 28),
                  ],
                  if (dhikr.recommendedTimes.isNotEmpty) ...[
                    _SectionHeader(
                      title: l10n.recommendedTimesTitle,
                      icon: Iconsax.clock,
                    ),
                    const SizedBox(height: 12),
                    _buildRecommendedTimes(context, dhikr),
                    const SizedBox(height: 28),
                  ],
                  const SizedBox(
                    height: 100,
                  ), // Spacing for floating bottom bar
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating Glassmorphic Bottom Action Bar
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: SafeArea(
              child: Row(
                children: [
                  if (isInProgress) ...[
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.progress,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$currentCount / $targetCount',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 52,
                      child: AppButton.primary(
                        icon: Iconsax.finger_scan,
                        label: isCompleted
                            ? l10n.completed
                            : isInProgress
                            ? l10n.continue_
                            : l10n.start,
                        isExpanded: true,
                        onPressed:
                            isCompleted &&
                                (progress?.repeatEnabled ?? false) == false
                            ? null
                            : () => context.push(
                                AppRoutes.counter,
                                extra: dhikr.id,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAzkar(BuildContext context, Dhikr dhikr) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return dhikr.azkar.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final showIndex = dhikr.azkar.length > 1;

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showIndex) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    AppIconButton(
                      icon: Iconsax.volume_high,
                      color: theme.colorScheme.primary,
                      onPressed: null,
                      size: 36,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Arabic Text Display
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.arabicText,
                  style: const TextStyle(
                    fontSize: 26,
                    fontFamily:
                        'Amiri', // Recommending an authentic Arabic font family
                    fontWeight: FontWeight.bold,
                    height: 2.0,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(height: 14),

              // Transliteration & Translation
              if (item.transliteration.isNotEmpty) ...[
                Text(
                  item.transliteration,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
              ],
              Text(
                item.translation,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Target Badges
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.repeat,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${item.targetCount}× ${l10n.recitations}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (item.isSunnahCount)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade700.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.verify,
                            size: 16,
                            color: Colors.amber.shade800,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.sunnahCount,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              // Note Banner
              if (item.note != null && item.note!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border(
                      left: BorderSide(
                        color: theme.colorScheme.secondary,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Iconsax.lamp,
                        size: 18,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.note!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildReferences(BuildContext context, Dhikr dhikr) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return dhikr.references.map((ref) {
      final isQuran = ref.type == ReferenceType.quran;
      final badgeColor = isQuran ? Colors.teal : theme.colorScheme.primary;

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isQuran ? Iconsax.book : Iconsax.book,
                size: 20,
                color: badgeColor,
              ),
            ),
            title: Text(
              ref.source,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (ref.text != null && ref.text!.isNotEmpty)
                    Text(
                      ref.text!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 2),
                  if (ref.narrator != null && ref.narrator!.isNotEmpty)
                    Text(
                      l10n.narratedBy(ref.narrator!),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  if (ref.surah != null)
                    Text(
                      ref.verse != null
                          ? l10n.surahVerse(ref.surah!, ref.verse!)
                          : l10n.surahOnly(ref.surah!),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  if (ref.referenceNumber != null)
                    Text(
                      l10n.refNo(ref.referenceNumber!),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
            trailing: ref.grade != null && ref.grade!.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      ref.grade!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildBenefits(BuildContext context, Dhikr dhikr) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: dhikr.benefits.asMap().entries.map((entry) {
            final isLast = entry.key == dhikr.benefits.length - 1;
            return Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade500.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.star1,
                      size: 18,
                      color: Colors.amber.shade800,
                    ),
                  ),
                  title: Text(
                    entry.value,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                  dense: true,
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    indent: 56,
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.3,
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRecommendedTimes(BuildContext context, Dhikr dhikr) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: dhikr.recommendedTimes
          .map(
            (t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Iconsax.clock,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    t,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final Dhikr dhikr;

  const _HeaderSection({required this.dhikr});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (dhikr.arabicTitle.isNotEmpty) ...[
          Center(
            child: Text(
              dhikr.arabicTitle,
              style: const TextStyle(
                fontSize: 28,
                fontFamily: 'Amiri',
                fontWeight: FontWeight.bold,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (dhikr.description.isNotEmpty) ...[
          Text(
            dhikr.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MetaChip(
              label: _categoryLabel(dhikr.category, l10n),
              icon: Iconsax.category,
            ),
            _MetaChip(
              label: _typeLabel(dhikr.type, l10n),
              icon: Iconsax.layer,
            ),
            if (dhikr.totalTargetCount > 0)
              _MetaChip(
                label: l10n.target(dhikr.totalTargetCount),
                icon: Iconsax.setting_4,
              ),
          ],
        ),
      ],
    );
  }

  String _categoryLabel(DhikrCategory c, AppLocalizations l10n) {
    switch (c) {
      case DhikrCategory.general:
        return l10n.categoryGeneral;
      case DhikrCategory.morning:
        return l10n.categoryMorning;
      case DhikrCategory.evening:
        return l10n.categoryEvening;
      case DhikrCategory.afterSalah:
        return l10n.categoryAfterSalah;
      case DhikrCategory.beforeSleep:
        return l10n.categoryBeforeSleep;
      case DhikrCategory.friday:
        return l10n.categoryFriday;
      case DhikrCategory.forgiveness:
        return l10n.categoryForgiveness;
      case DhikrCategory.protection:
        return l10n.categoryProtection;
      case DhikrCategory.praise:
        return l10n.categoryPraise;
      case DhikrCategory.salawat:
        return l10n.categorySalawat;
    }
  }

  String _typeLabel(DhikrType t, AppLocalizations l10n) {
    switch (t) {
      case DhikrType.single:
        return l10n.typeSingle;
      case DhikrType.collection:
        return l10n.typeCollection;
      case DhikrType.dua:
        return l10n.typeDua;
      case DhikrType.quran:
        return l10n.typeQuran;
    }
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _MetaChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon, this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
