import 'package:flutter/material.dart';
import 'package:relines/state/colors.dart';

/// An alternative to IconButton.
class CircleButton extends StatelessWidget {
  /// Tap callback.
  final VoidCallback onTap;

  /// Typically an Icon.
  final Widget icon;

  /// Size in radius of the widget.
  final double radius;

  /// Widget content backrgound color.
  final Color backgroundColor;

  final double elevation;

  final String tooltip;

  CircleButton({
    this.onTap,
    @required this.icon,
    this.radius = 20.0,
    this.elevation = 0.0,
    this.backgroundColor = Colors.black12,
    this.tooltip = "",
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2.0,
      shape: CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onTap,
          iconSize: 40.0,
          color: stateColors.foreground.withOpacity(0.6),
          icon: icon,
        ),
      ),
    );
  }
}
