import 'package:flutter/material.dart';

class EmptyContent extends StatelessWidget {
  final Widget icon;
  final Widget subtitle;
  final Widget title;
  final Function onRefresh;

  EmptyContent({
    this.icon,
    this.onRefresh,
    this.subtitle,
    @required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        children: <Widget>[
          if (icon != null) icon,
          title,
          if (subtitle != null) subtitle,
          if (onRefresh != null)
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: IconButton(
                icon: Icon(Icons.refresh),
                onPressed: onRefresh,
              ),
            ),
        ],
      ),
    );
  }
}
