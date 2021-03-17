import 'package:flutter/material.dart';
import 'package:relines/state/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:relines/utils/fonts.dart';

class Rules extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final titleFontSize = 60.0;
    final textFontSize = 20.0;

    final textStyle = FontsUtils.mainStyle(
      color: stateColors.foreground,
      fontSize: textFontSize,
      fontWeight: FontWeight.w100,
    );

    return Container(
      width: 600.0,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "rules".tr(),
            style: TextStyle(
              color: stateColors.secondary,
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
              bottom: 24.0,
            ),
            child: Opacity(
              opacity: 0.6,
              child: RichText(
                text: TextSpan(
                  text: "rules_1".tr(),
                  style: textStyle,
                  children: [],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 24.0,
            ),
            child: Opacity(
              opacity: 0.6,
              child: RichText(
                text: TextSpan(
                  text: "rules_2".tr(),
                  style: textStyle,
                  children: [],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 24.0,
            ),
            child: Opacity(
              opacity: 0.6,
              child: RichText(
                text: TextSpan(
                  text: "rules_3".tr(),
                  style: textStyle,
                  children: [],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
