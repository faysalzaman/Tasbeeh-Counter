import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/l10n_extension.dart';
import '../../models/dhikr.dart';
import '../../providers/dhikr_provider.dart';
import '../../router/app_router.dart';

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
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(l10n.noCustomWazifas, style: theme.textTheme.titleMedium),
        ),
      );
    }

    final targetCount = dhikr.totalTargetCount;
    final currentCount = progress?.currentCount ?? 0;
    final isInProgress = currentCount > 0 && currentCount < targetCount;
    final isCompleted = progress?.isCompleted ?? false;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
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
              IconButton(
                icon: const Icon(Icons.bookmark_border_rounded),
                onPressed: () {},
                tooltip: 'Save',
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {},
                tooltip: 'Share',
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
                        Icons.auto_awesome,
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
                      title: 'Azkar Recitations',
                      count: dhikr.azkar.length,
                      icon: Icons.menu_book_rounded,
                    ),
                    const SizedBox(height: 12),
                    ..._buildAzkar(context, dhikr),
                    const SizedBox(height: 28),
                  ],
                  if (dhikr.references.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'References',
                      count: dhikr.references.length,
                      icon: Icons.verified_outlined,
                    ),
                    const SizedBox(height: 12),
                    ..._buildReferences(context, dhikr),
                    const SizedBox(height: 28),
                  ],
                  if (dhikr.benefits.isNotEmpty) ...[
                    const _SectionHeader(
                      title: 'Benefits & Virtues',
                      icon: Icons.star_outline_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildBenefits(context, dhikr),
                    const SizedBox(height: 28),
                  ],
                  if (dhikr.recommendedTimes.isNotEmpty) ...[
                    const _SectionHeader(
                      title: 'Recommended Times',
                      icon: Icons.schedule_rounded,
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
                            'Progress',
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
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                        onPressed:
                            isCompleted &&
                                (progress?.repeatEnabled ?? false) == false
                            ? null
                            : () => context.push(
                                AppRoutes.counter,
                                extra: dhikr.id,
                              ),
                        icon: const Icon(Icons.fingerprint_rounded, size: 22),
                        label: Text(
                          isCompleted
                              ? l10n.completed
                              : isInProgress
                              ? l10n.continue_
                              : l10n.start,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
                    IconButton(
                      icon: const Icon(Icons.volume_up_outlined, size: 20),
                      color: theme.colorScheme.primary,
                      onPressed: () {},
                      visualDensity: VisualDensity.compact,
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
                          Icons.repeat_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${item.targetCount}× Recitations',
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
                            Icons.verified_rounded,
                            size: 16,
                            color: Colors.amber.shade800,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Sunnah Count',
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
                        Icons.lightbulb_outline_rounded,
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
    return dhikr.references.map((ref) {
      final isQuran = ref.type == ReferenceType.quran;
      final badgeColor = isQuran ? Colors.teal : theme.colorScheme.primary;

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
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
              isQuran ? Icons.auto_stories_rounded : Icons.menu_book_rounded,
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
                    'Narrated by: ${ref.narrator}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                if (ref.surah != null)
                  Text(
                    'Surah ${ref.surah}${ref.verse != null ? ' [Verse ${ref.verse}]' : ''}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                if (ref.referenceNumber != null)
                  Text(
                    'Ref No: #${ref.referenceNumber}',
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
      );
    }).toList();
  }

  Widget _buildBenefits(BuildContext context, Dhikr dhikr) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
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
                    Icons.star_rounded,
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
                    Icons.access_time_rounded,
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
              label: _categoryLabel(dhikr.category),
              icon: Icons.category_outlined,
            ),
            _MetaChip(
              label: _typeLabel(dhikr.type),
              icon: Icons.layers_outlined,
            ),
            if (dhikr.totalTargetCount > 0)
              _MetaChip(
                label: 'Target: ${dhikr.totalTargetCount}',
                icon: Icons.adjust_rounded,
              ),
          ],
        ),
      ],
    );
  }

  String _categoryLabel(DhikrCategory c) {
    switch (c) {
      case DhikrCategory.general:
        return 'General';
      case DhikrCategory.morning:
        return 'Morning';
      case DhikrCategory.evening:
        return 'Evening';
      case DhikrCategory.afterSalah:
        return 'After Salah';
      case DhikrCategory.beforeSleep:
        return 'Before Sleep';
      case DhikrCategory.friday:
        return 'Friday';
      case DhikrCategory.forgiveness:
        return 'Forgiveness';
      case DhikrCategory.protection:
        return 'Protection';
      case DhikrCategory.praise:
        return 'Praise';
      case DhikrCategory.salawat:
        return 'Salawat';
    }
  }

  String _typeLabel(DhikrType t) {
    switch (t) {
      case DhikrType.single:
        return 'Single';
      case DhikrType.collection:
        return 'Collection';
      case DhikrType.dua:
        return 'Dua';
      case DhikrType.quran:
        return 'Quran';
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
