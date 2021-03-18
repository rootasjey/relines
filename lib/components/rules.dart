import 'package:flutter/material.dart';
import 'package:relines/state/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:relines/utils/fonts.dart';

class Rules extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final titleFontSize = 50.0;
    final textFontSize = 20.0;

    final textStyle = FontsUtils.mainStyle(
      color: stateColors.foreground,
      fontSize: textFontSize,
      fontWeight: FontWeight.w200,
    );

    final subtitleStyle = FontsUtils.mainStyle(
      color: stateColors.foreground,
      fontSize: textFontSize,
      fontWeight: FontWeight.w500,
    );

    return Container(
      width: 600.0,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "rules".tr().toUpperCase(),
            style: TextStyle(
              color: stateColors.accent,
              fontSize: titleFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          goal(
            subtitleStyle: subtitleStyle,
            textStyle: textStyle,
          ),
          score(
            subtitleStyle: subtitleStyle,
            textStyle: textStyle,
          ),
          options(
            subtitleStyle: subtitleStyle,
            textStyle: textStyle,
          ),
        ],
      ),
    );
  }

  Widget goal({
    @required TextStyle subtitleStyle,
    @required TextStyle textStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 24.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "goal".tr().toUpperCase(),
            style: subtitleStyle,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Opacity(
              opacity: 0.8,
              child: Text(
                "rules_1".tr(),
                style: textStyle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
            ),
            child: Opacity(
              opacity: 0.8,
              child: Text(
                "rules_example".tr(),
                style: textStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget score({
    @required TextStyle subtitleStyle,
    @required TextStyle textStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 24.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "score".tr().toUpperCase(),
            style: subtitleStyle,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Opacity(
              opacity: 0.8,
              child: Text(
                "rules_2".tr(),
                style: textStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget options({
    @required TextStyle subtitleStyle,
    @required TextStyle textStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 24.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "options".tr().toUpperCase(),
            style: subtitleStyle,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Opacity(
              opacity: 0.8,
              child: Text(
                "rules_3".tr(),
                style: textStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
