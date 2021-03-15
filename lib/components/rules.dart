import 'package:flutter/material.dart';
import 'package:relines/state/colors.dart';

class Rules extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final titleFontSize = 60.0;
    final textFontSize = 16.0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Rules",
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
                  text:
                      "Each round, you have to guess the author or the reference "
                      "of the displayed quote. The question type alternate randomly. "
                      "For example, on the 1st round, you must guess the author, "
                      "and on the next 2nd round, you must guess the reference.",
                  style: TextStyle(
                    color: stateColors.foreground,
                    fontSize: textFontSize,
                    fontWeight: FontWeight.w100,
                  ),
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
                  text: "For each good answer, you earn 10 points. "
                      "Wrong answers make you loose 5 points."
                      "1 point is used if you skip one question.",
                  style: TextStyle(
                    color: stateColors.foreground,
                    fontSize: textFontSize,
                    fontWeight: FontWeight.w100,
                  ),
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
                  text: "You can choose a game in 5 questions, "
                      "10 questions or 20 questions.",
                  style: TextStyle(
                    color: stateColors.foreground,
                    fontSize: textFontSize,
                    fontWeight: FontWeight.w100,
                  ),
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
                  text: "Save your progress and your games "
                      "by connecting to your account. Or create one "
                      "if you didn't already.",
                  style: TextStyle(
                    color: stateColors.foreground,
                    fontSize: textFontSize,
                    fontWeight: FontWeight.w100,
                  ),
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
