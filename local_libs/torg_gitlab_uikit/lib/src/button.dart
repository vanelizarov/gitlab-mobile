import 'package:flutter/cupertino.dart';

import 'colors.dart';
import 'appearance.dart';

const Duration _kOpacityChangeDuration = Duration(milliseconds: 100);
final Tween<double> _kOpacityChangeTween = Tween<double>(begin: 1.0, end: 0.75);

class Button extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  get isDisabled => onPressed == null;

  Button({
    @required this.child,
    @required this.onPressed,
  });

  @override
  State<StatefulWidget> createState() => _ButtonState();
}

class _ButtonState extends State<Button> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _fadeAnimation;

  bool _heldDown = false;

  _onTapDown(_) {
    if (!_heldDown) {
      _heldDown = true;
      _animate();
    }
  }

  _onTapUp(_) {
    if (_heldDown) {
      _heldDown = false;
      _animate();
    }
  }

  _onTapCancel() {
    if (_heldDown) {
      _heldDown = false;
      _animate();
    }
  }

  void _animate() {
    if (_animationController.isAnimating) {
      return;
    }

    final bool wasHeldDown = _heldDown;
    final TickerFuture ticker = _heldDown
        ? _animationController.animateTo(1.0, duration: _kOpacityChangeDuration)
        : _animationController.animateTo(0.0,
            duration: _kOpacityChangeDuration);

    ticker.then<void>((void value) {
      if (mounted && wasHeldDown != _heldDown) {
        _animate();
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      value: 0.0,
      vsync: this,
    );

    _fadeAnimation = _animationController
        .drive(CurveTween(curve: Curves.decelerate))
        .drive(_kOpacityChangeTween);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animationController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = !widget.isDisabled;

    return GestureDetector(
      onTap: widget.onPressed,
      onTapUp: isEnabled ? _onTapUp : null,
      onTapDown: isEnabled ? _onTapDown : null,
      onTapCancel: isEnabled ? _onTapCancel : null,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: kMinActionWidgetSize,
            minWidth: kMinActionWidgetSize,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: widget.isDisabled ? Colors.greyHeather : Colors.blue,
            ),
            child: Center(
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class ButtonText extends StatelessWidget {
  final String text;

  ButtonText({
    Key key,
    this.text,
  })  : assert(text != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
      ),
    );
  }
}
