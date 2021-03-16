import 'package:flutter/material.dart';
import 'package:relines/utils/fonts.dart';

class GameTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      "Relines",
      style: FontsUtils.pacificoStyle(
        fontSize: 60.0,
      ),
    );
  }
}
