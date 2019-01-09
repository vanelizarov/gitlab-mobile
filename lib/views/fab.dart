import 'package:flutter/cupertino.dart';

import 'package:uikit/uikit.dart' as ui;

class Fab extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final BorderRadiusGeometry borderRadius;

  Fab({
    @required this.icon,
    @required this.onTap,
    this.iconColor = ui.Colors.white,
    this.borderRadius,
  })  : assert(icon != null),
        assert(onTap != null);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: 40,
        height: 40,
        child: Center(
          child: Icon(
            icon,
            color: iconColor,
            size: 16.0,
          ),
        ),
        decoration: BoxDecoration(
          color: ui.Colors.deepBlue,
          borderRadius: borderRadius,
        ),
      ),
      onTap: onTap,
    );
  }
}
