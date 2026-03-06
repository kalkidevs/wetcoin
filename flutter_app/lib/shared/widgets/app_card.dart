import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  AppCard — enhanced card widget
//
//  Variants:
//    • elevated  — default floating card with shadow
//    • filled    — flat surface-variant fill, no shadow
//    • outlined  — explicit border, no shadow
//    • ghost     — transparent bg, no shadow (layout only)
//    • gradient  — LinearGradient background with optional shimmer
//
//  Features:
//    • Animated press scale + ink ripple on tap
//    • Optional header row  (title + subtitle + trailing widget)
//    • Optional badge / "new" indicator dot
//    • Optional gradient or solid custom color
//    • Disabled state (reduced opacity, no ripple)
//    • Shimmer loading skeleton built-in
// ─────────────────────────────────────────────────────────────────────────────

enum AppCardVariant { elevated, filled, outlined, ghost, gradient }

class AppCard extends StatefulWidget {
  // ── Content ──────────────────────────────────────────────────────────────
  final Widget? child;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  // ── Behaviour ─────────────────────────────────────────────────────────────
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool disabled;
  final bool isLoading;     // shows shimmer skeleton

  // ── Appearance ────────────────────────────────────────────────────────────
  final AppCardVariant variant;
  final Color? color;
  final LinearGradient? gradient;
  final EdgeInsetsGeometry padding;
  final double? elevation;
  final double borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final bool showBadge;
  final Color? badgeColor;

  const AppCard({
    super.key,
    this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.disabled = false,
    this.isLoading = false,
    this.variant = AppCardVariant.elevated,
    this.color,
    this.gradient,
    this.padding = const EdgeInsets.all(16),
    this.elevation,
    this.borderRadius = 16,
    this.borderColor,
    this.borderWidth = 1,
    this.showBadge = false,
    this.badgeColor,
  }) : assert(child != null || title != null,
  'Provide at least a child or a title.');

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 180),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  // ── Resolve colours from theme ───────────────────────────────────────────
  Color _resolveColor(BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    if (widget.color != null) return widget.color!;
    return switch (widget.variant) {
      AppCardVariant.elevated  => cs.surface,
      AppCardVariant.filled    => cs.surfaceContainerHighest,
      AppCardVariant.outlined  => cs.surface,
      AppCardVariant.ghost     => Colors.transparent,
      AppCardVariant.gradient  => Colors.transparent,
    };
  }

  double _resolveElevation() {
    if (widget.elevation != null) return widget.elevation!;
    return switch (widget.variant) {
      AppCardVariant.elevated  => 3,
      AppCardVariant.filled    => 0,
      AppCardVariant.outlined  => 0,
      AppCardVariant.ghost     => 0,
      AppCardVariant.gradient  => 4,
    };
  }

  BorderSide _resolveBorder(BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    return switch (widget.variant) {
      AppCardVariant.outlined => BorderSide(
          color: widget.borderColor ?? cs.outline,
          width: widget.borderWidth),
      AppCardVariant.filled => BorderSide(
          color: widget.borderColor ?? cs.outlineVariant,
          width: widget.borderWidth),
      _ => widget.borderColor != null
          ? BorderSide(color: widget.borderColor!, width: widget.borderWidth)
          : BorderSide.none,
    };
  }

  // ── Shimmer skeleton ─────────────────────────────────────────────────────
  Widget _buildSkeleton(BuildContext ctx) {
    return _SkeletonShimmer(
      borderRadius: widget.borderRadius,
      height: 96,
    );
  }

  // ── Optional header ──────────────────────────────────────────────────────
  Widget? _buildHeader(BuildContext ctx) {
    if (widget.title == null) return null;
    final tt = Theme.of(ctx).textTheme;
    final cs = Theme.of(ctx).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.leading != null) ...[
          widget.leading!,
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title!,
                  style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface)),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(widget.subtitle!,
                    style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant)),
              ],
            ],
          ),
        ),
        if (widget.trailing != null) ...[
          const SizedBox(width: 12),
          widget.trailing!,
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(widget.borderRadius);
    final bool tappable =
        (widget.onTap != null || widget.onLongPress != null) && !widget.disabled;

    Widget content = widget.isLoading
        ? _buildSkeleton(context)
        : Padding(
      padding: widget.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_buildHeader(context) != null) ...[
            _buildHeader(context)!,
            if (widget.child != null) const SizedBox(height: 12),
          ],
          if (widget.child != null) widget.child!,
        ],
      ),
    );

    // Gradient overlay
    if (widget.variant == AppCardVariant.gradient && widget.gradient != null) {
      content = Container(
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: br,
        ),
        child: content,
      );
    }

    Widget card = Card(
      color: _resolveColor(context),
      elevation: _resolveElevation(),
      shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.12),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: br,
        side: _resolveBorder(context),
      ),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: tappable
          ? InkWell(
        onTap: () {
          _pressCtrl.forward().then((_) => _pressCtrl.reverse());
          widget.onTap?.call();
        },
        onLongPress: widget.onLongPress,
        onTapDown: (_) => _pressCtrl.forward(),
        onTapCancel: () => _pressCtrl.reverse(),
        borderRadius: br,
        splashColor:
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        highlightColor:
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
        child: content,
      )
          : content,
    );

    // Press-scale wrapper
    if (tappable) {
      card = ListenableBuilder(
        listenable: _scaleAnim,
        builder: (_, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: card,
      );
    }

    // Disabled overlay
    if (widget.disabled) {
      card = Opacity(opacity: 0.45, child: card);
    }

    // Badge dot
    if (widget.showBadge) {
      card = Stack(
        clipBehavior: Clip.none,
        children: [
          card,
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: widget.badgeColor ??
                    Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
                border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2),
              ),
            ),
          ),
        ],
      );
    }

    return card;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shimmer skeleton painter
// ─────────────────────────────────────────────────────────────────────────────
class _SkeletonShimmer extends StatefulWidget {
  final double borderRadius;
  final double height;
  const _SkeletonShimmer({required this.borderRadius, required this.height});

  @override
  State<_SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<_SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _anim = Tween<double>(begin: -2, end: 2).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base   = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8);
    final shine  = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5);

    return ListenableBuilder(
      listenable: _anim,
      builder: (_, __) => Container(
        height: widget.height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end:   Alignment(_anim.value + 1, 0),
            colors: [base, shine, base],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonBar(width: 140, height: 14, color: base.withValues(alpha: 0.6)),
            const SizedBox(height: 8),
            _SkeletonBar(width: 220, height: 10, color: base.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  final double width, height;
  final Color color;
  const _SkeletonBar(
      {required this.width, required this.height, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
        color: color, borderRadius: BorderRadius.circular(6)),
  );
}