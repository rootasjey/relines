import 'package:flutter/material.dart';

class QuoteQuestion extends StatelessWidget {
  final String quoteName;
  final Color accentColor;

  const QuoteQuestion({
    Key key,
    @required this.quoteName,
    @required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 700.0),
      child: Opacity(
        opacity: 0.8,
        child: Text(
          quoteName,
          style: TextStyle(
            fontSize: 42.0,
            fontWeight: FontWeight.w300,
            decoration: TextDecoration.underline,
            decorationColor: accentColor.withOpacity(0.2),
          ),
        ),
      ),
    );
  }
}
