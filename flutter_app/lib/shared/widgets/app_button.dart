import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  AppButton — enhanced button widget
//
//  Types  :  primary | secondary | outline | ghost | danger | success
//  Sizes  :  small | medium (default) | large
//
//  Features:
//    • Animated press-scale with spring bounce
//    • Haptic feedback on tap
//    • Loading spinner (keeps button width stable)
//    • Leading AND trailing icon support
//    • Icon-only circular/square variant
//    • Full-width expansion option
//    • Gradient background (primary only)
//    • Disabled state with correct opacity
//    • All interactions respect isLoading + disabled
// ─────────────────────────────────────────────────────────────────────────────

enum AppButtonType { primary, secondary, outline, ghost, danger, success }
enum AppButtonSize { small, medium, large }

class AppButton extends StatefulWidget {
  // ── Content ──────────────────────────────────────────────────────────────
  final String? label;             // null = icon-only mode
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  // ── Behaviour ─────────────────────────────────────────────────────────────
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool disabled;
  final bool fullWidth;
  final bool useGradient;          // gradient bg for primary buttons
  final bool haptic;               // HapticFeedback.lightImpact on tap

  // ── Appearance ────────────────────────────────────────────────────────────
  final AppButtonType type;
  final AppButtonSize size;

  const AppButton({
    super.key,
    this.label,
    this.leadingIcon,
    this.trailingIcon,
    required this.onPressed,
    this.isLoading  = false,
    this.disabled   = false,
    this.fullWidth  = false,
    this.useGradient = false,
    this.haptic     = true,
    this.type       = AppButtonType.primary,
    this.size       = AppButtonSize.medium,
  }) : assert(label != null || leadingIcon != null,
  'Provide at least a label or an icon.');

  // ── Convenience constructors ──────────────────────────────────────────────

  /// Full-width primary CTA — typical form submit button
  const AppButton.cta({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading  = false,
    this.disabled   = false,
    this.useGradient = true,
    this.haptic     = true,
  })  : type     = AppButtonType.primary,
        size     = AppButtonSize.large,
        fullWidth = true;

  /// Compact destructive action (delete, remove, etc.)
  const AppButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.isLoading  = false,
    this.disabled   = false,
    this.haptic     = true,
  })  : type        = AppButtonType.danger,
        size        = AppButtonSize.medium,
        fullWidth   = false,
        trailingIcon = null,
        useGradient  = false;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut,
          reverseCurve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  // ── Size tokens ───────────────────────────────────────────────────────────
  double get _height => switch (widget.size) {
    AppButtonSize.small  => 36,
    AppButtonSize.medium => 48,
    AppButtonSize.large  => 56,
  };

  double get _fontSize => switch (widget.size) {
    AppButtonSize.small  => 13,
    AppButtonSize.medium => 15,
    AppButtonSize.large  => 16,
  };

  double get _iconSize => switch (widget.size) {
    AppButtonSize.small  => 16,
    AppButtonSize.medium => 18,
    AppButtonSize.large  => 20,
  };

  EdgeInsets get _padding => switch (widget.size) {
    AppButtonSize.small  => const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
    AppButtonSize.medium => const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
    AppButtonSize.large  => const EdgeInsets.symmetric(horizontal: 28, vertical: 0),
  };

  double get _borderRadius => switch (widget.size) {
    AppButtonSize.small  => 8,
    AppButtonSize.medium => 12,
    AppButtonSize.large  => 14,
  };

  // ── Colour resolution ─────────────────────────────────────────────────────
  Color get _bgColor => switch (widget.type) {
    AppButtonType.primary   => AppColors.primary,
    AppButtonType.secondary => AppColors.secondary,
    AppButtonType.outline   => Colors.transparent,
    AppButtonType.ghost     => Colors.transparent,
    AppButtonType.danger    => AppColors.error,
    AppButtonType.success   => AppColors.success,
  };

  Color get _fgColor => switch (widget.type) {
    AppButtonType.primary   => Colors.white,
    AppButtonType.secondary => Colors.white,
    AppButtonType.outline   => AppColors.primary,
    AppButtonType.ghost     => AppColors.primary,
    AppButtonType.danger    => Colors.white,
    AppButtonType.success   => Colors.white,
  };

  Color? get _borderColor => switch (widget.type) {
    AppButtonType.outline => AppColors.primary,
    AppButtonType.danger  => AppColors.error,
    _                     => null,
  };

  Color get _shadowColor => switch (widget.type) {
    AppButtonType.primary   => AppColors.primary.withOpacity(0.35),
    AppButtonType.secondary => AppColors.secondary.withOpacity(0.30),
    AppButtonType.danger    => AppColors.error.withOpacity(0.30),
    AppButtonType.success   => AppColors.success.withOpacity(0.30),
    _                       => Colors.transparent,
  };

  bool get _hasShadow =>
      widget.type != AppButtonType.outline &&
          widget.type != AppButtonType.ghost;

  bool get _isEnabled => !widget.disabled && !widget.isLoading;

  void _handleTap() {
    if (!_isEnabled) return;
    if (widget.haptic) HapticFeedback.lightImpact();
    _pressCtrl.forward().then((_) => _pressCtrl.reverse());
    widget.onPressed?.call();
  }

  // ── Spinner widget ────────────────────────────────────────────────────────
  Widget _spinner() => SizedBox(
    width:  _iconSize,
    height: _iconSize,
    child: CircularProgressIndicator(
      strokeWidth: 2,
      color: _fgColor,
    ),
  );

  // ── Button content row ────────────────────────────────────────────────────
  Widget _content() {
    final bool iconOnly = widget.label == null;

    if (widget.isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _spinner(),
          if (!iconOnly) ...[
            const SizedBox(width: 8),
            Text(
              'Loading...',
              style: TextStyle(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.w600,
                  color: _fgColor.withOpacity(0.7)),
            ),
          ],
        ],
      );
    }

    if (iconOnly) {
      return Icon(widget.leadingIcon, size: _iconSize, color: _fgColor);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.leadingIcon != null) ...[
          Icon(widget.leadingIcon, size: _iconSize, color: _fgColor),
          const SizedBox(width: 8),
        ],
        Text(
          widget.label!,
          style: TextStyle(
            fontSize:   _fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: _fgColor,
          ),
        ),
        if (widget.trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(widget.trailingIcon, size: _iconSize, color: _fgColor),
        ],
      ],
    );
  }

  // ── Core button ───────────────────────────────────────────────────────────
  Widget _buildButton(BuildContext ctx) {
    final br = BorderRadius.circular(_borderRadius);
    final bool iconOnly = widget.label == null;

    // Gradient background
    if (widget.useGradient &&
        (widget.type == AppButtonType.primary ||
            widget.type == AppButtonType.success)) {
      return GestureDetector(
        onTap:    _handleTap,
        onTapDown: (_) { if (_isEnabled) _pressCtrl.forward(); },
        onTapCancel:  () => _pressCtrl.reverse(),
        child: Container(
          height: _height,
          width:  iconOnly ? _height : null,
          padding: iconOnly ? EdgeInsets.zero : _padding,
          decoration: BoxDecoration(
            gradient: widget.type == AppButtonType.primary
                ? AppColors.primaryGradient
                : LinearGradient(
              colors: [AppColors.success,
                AppColors.success.withGreen(
                    (AppColors.success.green + 30).clamp(0, 255))],
              begin: Alignment.topLeft,
              end:   Alignment.bottomRight,
            ),
            borderRadius: br,
            boxShadow: _hasShadow
                ? [BoxShadow(
              color:       _shadowColor,
              blurRadius:  12,
              offset:      const Offset(0, 4),
            )]
                : null,
          ),
          child: Center(child: _content()),
        ),
      );
    }

    // Standard Material button
    final style = ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return _bgColor.withOpacity(
              widget.type == AppButtonType.outline ||
                  widget.type == AppButtonType.ghost
                  ? 0
                  : 0.4);
        }
        return _bgColor;
      }),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return _fgColor.withOpacity(0.45);
        }
        return _fgColor;
      }),
      overlayColor: MaterialStateProperty.all(
          _fgColor.withOpacity(0.10)),
      side: MaterialStateProperty.resolveWith((states) {
        if (_borderColor == null) return BorderSide.none;
        return BorderSide(
          color: states.contains(MaterialState.disabled)
              ? _borderColor!.withOpacity(0.35)
              : _borderColor!,
          width: 1.5,
        );
      }),
      shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: br)),
      padding: MaterialStateProperty.all(
          iconOnly ? EdgeInsets.zero : _padding),
      minimumSize: MaterialStateProperty.all(
          iconOnly ? Size(_height, _height) : Size(0, _height)),
      maximumSize: MaterialStateProperty.all(
          widget.fullWidth
              ? const Size(double.infinity, 200)
              : const Size(double.infinity, 200)),
      elevation: MaterialStateProperty.resolveWith((states) {
        if (!_hasShadow) return 0;
        if (states.contains(MaterialState.pressed)) return 1;
        if (states.contains(MaterialState.disabled)) return 0;
        return switch (widget.size) {
          AppButtonSize.small  => 2.0,
          AppButtonSize.medium => 3.0,
          AppButtonSize.large  => 4.0,
        };
      }),
      shadowColor: MaterialStateProperty.all(_shadowColor),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      animationDuration: const Duration(milliseconds: 100),
    );

    return widget.type == AppButtonType.outline ||
        widget.type == AppButtonType.ghost
        ? OutlinedButton(
      onPressed: _isEnabled ? _handleTap : null,
      style: style,
      child: _content(),
    )
        : ElevatedButton(
      onPressed: _isEnabled ? _handleTap : null,
      style: style,
      child: _content(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget btn = _buildButton(context);

    // Full-width stretch
    if (widget.fullWidth) {
      btn = SizedBox(width: double.infinity, child: btn);
    }

    // Press-scale animation
    btn = AnimatedBuilder(
      animation: _scaleAnim,
      builder: (_, child) =>
          Transform.scale(scale: _scaleAnim.value, child: child),
      child: btn,
    );

    // Disabled wrapper (no pointer events)
    if (!_isEnabled) {
      btn = IgnorePointer(ignoring: widget.isLoading, child: btn);
    }

    return btn;
  }
}