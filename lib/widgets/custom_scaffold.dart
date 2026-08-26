import 'package:flutter/material.dart';

/// A professional, drop-in replacement for [Scaffold].
///
/// Automatically:
/// - Applies default content padding
/// - Wraps content in [SafeArea] (top/bottom aware, notch & gesture-bar safe)
/// - Adapts to current theme (light/dark, colors, surface)
/// - Supports scrollable bodies, pull-to-refresh, loading overlay,
///   and empty states — without any extra boilerplate per screen.
///
/// Usage:
/// ```dart
/// CustomScaffold(
///   title: 'Home',
///   body: Text('Hello'),
/// )
/// ```
class CustomScaffold extends StatelessWidget {
  const CustomScaffold({
    super.key,
    required this.body,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.drawer,
    this.endDrawer,
    this.padding = const EdgeInsets.all(16),
    this.scrollable = false,
    this.onRefresh,
    this.isLoading = false,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.centerTitle = true,
    this.showAppBar = true,
    this.elevation = 0,
    this.extendBodyBehindAppBar = false,
    this.bottom,
  });

  /// Simple string title. Ignored if [titleWidget] is provided.
  final String? title;

  /// Custom title widget (overrides [title]).
  final Widget? titleWidget;

  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Widget? drawer;
  final Widget? endDrawer;

  /// Default padding applied around [body]. Set to [EdgeInsets.zero]
  /// for full-bleed content (maps, images, custom scroll views).
  final EdgeInsetsGeometry padding;

  /// Wraps [body] in a [SingleChildScrollView] automatically.
  final bool scrollable;

  /// If provided, enables pull-to-refresh (implies [scrollable]).
  final Future<void> Function()? onRefresh;

  /// Shows a themed loading overlay above the body.
  final bool isLoading;

  final bool safeAreaTop;
  final bool safeAreaBottom;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool centerTitle;

  /// Set to false for screens that shouldn't render an AppBar at all.
  final bool showAppBar;
  final double elevation;
  final bool extendBodyBehindAppBar;

  /// Widget to place at the bottom of the AppBar (e.g. a [TabBar]).
  final PreferredSizeWidget? bottom;

  bool get _hasAppBar =>
      showAppBar &&
      (title != null ||
          titleWidget != null ||
          actions != null ||
          leading != null ||
          bottom != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget content = body;

    if (scrollable || onRefresh != null) {
      content = SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        child: content,
      );
    } else if (padding != EdgeInsets.zero) {
      content = Padding(padding: padding, child: content);
    }

    if (onRefresh != null) {
      content = RefreshIndicator(
        onRefresh: onRefresh!,
        color: colorScheme.primary,
        backgroundColor: colorScheme.surface,
        child: content,
      );
    }

    content = SafeArea(
      top: safeAreaTop,
      bottom: safeAreaBottom,
      child: content,
    );

    if (isLoading) {
      content = Stack(
        children: [
          content,
          Positioned.fill(
            child: Container(
              color: colorScheme.surface.withValues(alpha: 0.6),
              child: Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: _hasAppBar
          ? AppBar(
              title: titleWidget ?? (title != null ? Text(title!) : null),
              actions: actions,
              leading: leading,
              automaticallyImplyLeading: automaticallyImplyLeading,
              centerTitle: centerTitle,
              elevation: elevation,
              bottom: bottom,
              backgroundColor:
                  theme.appBarTheme.backgroundColor ?? colorScheme.surface,
              foregroundColor:
                  theme.appBarTheme.foregroundColor ?? colorScheme.onSurface,
              surfaceTintColor: Colors.transparent,
            )
          : null,
      drawer: drawer,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      body: content,
    );
  }
}
