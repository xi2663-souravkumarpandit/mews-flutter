import 'package:flutter/widgets.dart';
import 'package:optimus/optimus_icons.dart';
import 'package:optimus/src/border_radius.dart';
import 'package:optimus/src/theme/theme.dart';

class CheckboxTick extends StatefulWidget {
  const CheckboxTick({
    super.key,
    required this.isEnabled,
    required this.onChanged,
    required this.onTap,
    this.isChecked,
    this.isError = false,
  });

  final bool isEnabled;
  final ValueChanged<bool> onChanged;
  final bool? isChecked;
  final bool isError;
  final VoidCallback onTap;

  @override
  State<CheckboxTick> createState() => _CheckboxTickState();
}

class _CheckboxTickState extends State<CheckboxTick> with ThemeGetter {
  bool _isHovering = false;
  bool _isTappedDown = false;

  _TickState get _state => widget.isChecked.toState;

  _InteractionState get _interactionState {
    if (!widget.isEnabled) return _InteractionState.disabled;
    if (_isTappedDown) return _InteractionState.active;
    if (_isHovering) return _InteractionState.hover;

    return _InteractionState.basic;
  }

  void _onHoverChanged(bool hovered) => setState(() => _isHovering = hovered);

  Color get _borderColor => widget.isError
      ? theme.tokens.backgroundInteractiveDangerDefault
      : _interactionState.borderColor(context);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _isTappedDown = true),
        onTapUp: (_) => setState(() => _isTappedDown = false),
        onTapCancel: () => setState(() => _isTappedDown = false),
        child: MouseRegion(
          onEnter: (_) => _onHoverChanged(true),
          onExit: (_) => _onHoverChanged(false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              color: _interactionState.fillColor(context, _state),
              border: _state.isUnchecked
                  ? Border.all(color: _borderColor, width: 1.5)
                  : null,
              borderRadius: const BorderRadius.all(borderRadius25),
            ),
            width: 16,
            height: 16,
            child:
                _CheckboxIcon(icon: _state.icon, isEnabled: widget.isEnabled),
          ),
        ),
      );
}

class _CheckboxIcon extends StatelessWidget {
  const _CheckboxIcon({this.icon, required this.isEnabled});

  final IconData? icon;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) => icon == null
      ? const SizedBox.shrink()
      : Center(
          child: Icon(
            icon,
            size: 10,
            color: isEnabled
                ? context.tokens.textStaticInverse
                : context.tokens.textDisabled,
          ),
        );
}

enum _TickState { checked, unchecked, undetermined }

extension on _TickState {
  IconData? get icon => switch (this) {
        _TickState.checked => OptimusIcons.done,
        _TickState.unchecked => null,
        _TickState.undetermined => OptimusIcons.minus_simple,
      };

  bool get isUnchecked => this == _TickState.unchecked;
}

enum _InteractionState { basic, hover, active, disabled }

extension on _InteractionState {
  Color? fillColor(BuildContext context, _TickState state) => switch (this) {
        _InteractionState.basic => state.isUnchecked
            ? null
            : context.tokens.backgroundInteractivePrimaryDefault,
        _InteractionState.hover => state.isUnchecked
            ? context.tokens.backgroundInteractiveNeutralSubtleHover
            : context.tokens.backgroundInteractivePrimaryHover,
        _InteractionState.active => state.isUnchecked
            ? context.tokens.backgroundInteractiveNeutralSubtleActive
            : context.tokens.backgroundInteractivePrimaryActive,
        _InteractionState.disabled =>
          state.isUnchecked ? null : context.tokens.backgroundDisabled,
      };

  Color borderColor(BuildContext context) => switch (this) {
        _InteractionState.basic =>
          context.tokens.borderInteractiveSecondaryDefault,
        _InteractionState.hover =>
          context.tokens.borderInteractiveSecondaryHover,
        _InteractionState.active =>
          context.tokens.borderInteractiveSecondaryActive,
        _InteractionState.disabled => context.tokens.borderDisabled,
      };
}

extension on bool? {
  _TickState get toState => switch (this) {
        true => _TickState.checked,
        false => _TickState.unchecked,
        null => _TickState.undetermined,
      };
}
