import 'package:flutter/material.dart';
import 'package:optimus/src/enabled.dart';
import 'package:optimus/src/link/link_variant.dart';
import 'package:optimus/src/spacing.dart';
import 'package:optimus/src/theme/optimus_tokens.dart';
import 'package:optimus/src/theme/theme.dart';

class BaseLink extends StatefulWidget {
  const BaseLink({
    super.key,
    required this.text,
    required this.textStyle,
    this.icon,
    this.onPressed,
    this.overflow,
    this.inherit = false,
    this.strong = false,
    this.variant = OptimusLinkVariant.primary,
  });

  final VoidCallback? onPressed;
  final TextStyle? textStyle;
  final Widget text;
  final Widget? icon;
  final bool strong;
  final bool inherit;
  final TextOverflow? overflow;
  final OptimusLinkVariant variant;

  @override
  State<BaseLink> createState() => _BaseLinkState();
}

class _BaseLinkState extends State<BaseLink> with ThemeGetter {
  bool _isHovering = false;
  bool _isTappedDown = false;

  void _handleHoverChange(bool isHovering) =>
      setState(() => _isHovering = isHovering);

  Color get _effectiveColor => widget.inherit ? _inheritedColor : _color;

  Color get _color {
    if (!_isEnabled) return widget.variant.getDisabledColor(tokens);
    if (_isTappedDown) return widget.variant.getTappedColor(tokens);
    if (_isHovering) return widget.variant.getHoveredColor(tokens);

    return widget.variant.getDefaultColor(tokens);
  }

  Color get _inheritedColor => widget.textStyle?.color ?? _color;

  bool get _isEnabled => widget.onPressed != null;

  TextStyle get _textStyle =>
      widget.textStyle ?? DefaultTextStyle.of(context).style;

  @override
  Widget build(BuildContext context) {
    final icon = widget.icon;

    final text = DefaultTextStyle(
      style: _textStyle.copyWith(
        color: _effectiveColor,
        overflow: widget.overflow,
        fontWeight: widget.strong ? FontWeight.w500 : FontWeight.w400,
        decoration: _isHovering ? null : TextDecoration.underline,
      ),
      child: widget.text,
    );

    final child = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              text,
              Padding(
                padding: const EdgeInsets.only(left: spacing100),
                child: IconTheme(
                  data: IconThemeData(color: _effectiveColor),
                  child: icon,
                ),
              ),
            ],
          )
        : text;

    return OptimusEnabled(
      isEnabled: _isEnabled,
      child: MouseRegion(
        onEnter: (_) => _handleHoverChange(true),
        onExit: (_) => _handleHoverChange(false),
        child: GestureDetector(
          onTap: widget.onPressed,
          onTapDown: (_) => setState(() => _isTappedDown = true),
          onTapUp: (_) => setState(() => _isTappedDown = false),
          onTapCancel: () => setState(() => _isTappedDown = false),
          child: child,
        ),
      ),
    );
  }
}

extension on OptimusLinkVariant {
  Color getDefaultColor(OptimusTokens tokens) => switch (this) {
        OptimusLinkVariant.primary => tokens.textInteractiveDefault,
        OptimusLinkVariant.basic => tokens.textStaticPrimary,
      };
  Color getHoveredColor(OptimusTokens tokens) => switch (this) {
        OptimusLinkVariant.primary => tokens.textInteractiveHover,
        OptimusLinkVariant.basic => tokens.textStaticTertiary,
      };
  Color getTappedColor(OptimusTokens tokens) => switch (this) {
        OptimusLinkVariant.primary => tokens.textInteractiveActive,
        OptimusLinkVariant.basic => tokens.textStaticPrimary,
      };
  Color getDisabledColor(OptimusTokens tokens) => tokens.textDisabled;
}
