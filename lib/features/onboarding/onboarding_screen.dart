import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/localization/l10n_extension.dart';
import '../../providers/settings_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/custom_scaffold.dart';
import 'package:iconsax/iconsax.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _selectedLanguage;

  final List<Map<String, String>> _languages = const [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'ar', 'name': 'Arabic', 'native': 'العربية'},
    {'code': 'ur', 'name': 'Urdu', 'native': 'اردو'},
  ];

  List<OnboardingPageData> _getPages(BuildContext context) {
    final l10n = context.l10n;
    return [
      OnboardingPageData(
        icon: Iconsax.finger_scan,
        title: l10n.onboardingTitle1,
        description: l10n.onboardingDesc1,
      ),
      OnboardingPageData(
        icon: Iconsax.archive_add,
        title: l10n.onboardingTitle2,
        description: l10n.onboardingDesc2,
      ),
      OnboardingPageData(
        icon: Iconsax.notification,
        title: l10n.onboardingTitle3,
        description: l10n.onboardingDesc3,
      ),
      OnboardingPageData(
        icon: Iconsax.save_2,
        title: l10n.onboardingTitle4,
        description: l10n.onboardingDesc4,
      ),
    ];
  }

  int get _totalPages => _getPages(context).length + 1; // +1 for language step

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _selectLanguage(String code) {
    setState(() => _selectedLanguage = code);
    ref.read(settingsProvider.notifier).updateLanguage(code);
  }

  Future<void> _finishOnboarding() async {
    await ref.read(settingsProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final pages = _getPages(context);

    return CustomScaffold(
      backgroundColor: theme.colorScheme.surface,
      showAppBar: false,
      padding: EdgeInsets.zero,
      body: Column(
        children: [
          // Top Bar with Skip Option
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Optional Step Counter Badge
                if (_currentPage > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_currentPage / ${pages.length}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),

                AppButton.text(
                  label: l10n.skip,
                  onPressed: _finishOnboarding,
                ),
              ],
            ),
          ),

          // Main Page Content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: _currentPage == 0
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: _totalPages,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildLanguageSelection(context);
                }

                final page = pages[index - 1];
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          page.icon,
                          size: 56,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 36),
                      Text(
                        page.title,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        page.description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),
          ),

          // Animated Page Indicator Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _totalPages,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Next / Continue Button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: AppButton.primary(
              label: _currentPage == _totalPages - 1
                  ? l10n.getStarted
                  : l10n.next,
              isExpanded: true,
              height: 56,
              onPressed: (_currentPage == 0 && _selectedLanguage == null)
                  ? null
                  : _nextPage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelection(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.language_square,
              size: 48,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            l10n.chooseLanguage,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.chooseLanguageSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ..._languages.map((lang) {
            final isSelected = _selectedLanguage == lang['code'];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
                    : theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: ListTile(
                  onTap: () {
                    _selectLanguage(lang['code']!);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        lang['native']![0],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    lang['name']!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    lang['native']!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: lang['code'] == 'ar' ? 'Amiri' : null,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Iconsax.tick_circle,
                          color: theme.colorScheme.primary,
                        )
                      : null,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;

  OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
  });
}
