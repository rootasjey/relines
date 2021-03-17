import 'package:flutter/material.dart';
import 'package:relines/state/colors.dart';
import 'package:relines/utils/constants.dart';
import 'package:unicons/unicons.dart';
import 'package:easy_localization/easy_localization.dart';

class Hud extends StatelessWidget {
  final bool isVisible;
  final bool hasChosenAnswer;
  final bool isCheckingAnswer;
  final int score;
  final int maxQuestions;
  final int currentQuestion;
  final VoidCallback onQuit;
  final VoidCallback onSkip;
  final VoidCallback onNextQuestion;

  const Hud({
    Key key,
    this.onQuit,
    this.onSkip,
    @required this.score,
    @required this.maxQuestions,
    @required this.currentQuestion,
    this.isVisible = true,
    @required this.hasChosenAnswer,
    @required this.onNextQuestion,
    @required this.isCheckingAnswer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return Container();
    }

    final size = MediaQuery.of(context).size;

    if (size.width < Constants.maxMobileWidth) {
      return rowLayout(context);
    }

    return cardLayout();
  }

  Widget cardLayout() {
    return Positioned(
      top: 160.0,
      right: 24.0,
      child: Container(
        width: 180.0,
        child: Card(
          elevation: 2.0,
          color: stateColors.tileBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
            side: BorderSide(
              color: stateColors.accent,
              width: 2.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    children: [
                      Icon(
                        UniconsLine.award,
                        color: Colors.yellow.shade800,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text("$score points"),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    children: [
                      Icon(
                        UniconsLine.question,
                        color: Colors.green,
                      ),
                      Text("question $currentQuestion / $maxQuestions"),
                    ],
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.start,
                  children: [
                    TextButton(
                      onPressed: onQuit,
                      child: Wrap(
                        children: [
                          Text("quit".tr()),
                        ],
                      ),
                      style: TextButton.styleFrom(
                        primary: Colors.pink,
                      ),
                    ),
                    TextButton(
                      onPressed: onSkip,
                      child: Wrap(
                        children: [
                          Text("skip".tr()),
                        ],
                      ),
                      style: TextButton.styleFrom(
                        primary: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget rowLayout(BuildContext context) {
    return Positioned(
      bottom: 0.0,
      left: 0.0,
      child: Container(
        height: 60.0,
        width: MediaQuery.of(context).size.width,
        child: Card(
          elevation: 2.0,
          margin: EdgeInsets.zero,
          color: stateColors.tileBackground,
          shape: Border(
            top: BorderSide(
              color: stateColors.accent,
              width: 2.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    children: [
                      Icon(
                        UniconsLine.award,
                        color: Colors.yellow.shade800,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text("$score points"),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    children: [
                      Icon(
                        UniconsLine.question,
                        color: Colors.green,
                      ),
                      Text("question $currentQuestion / $maxQuestions"),
                    ],
                  ),
                ),
                actionsButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget actionsButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasChosenAnswer)
            TextButton(
              onPressed: () {
                if (isCheckingAnswer) {
                  return;
                }

                onNextQuestion();
              },
              child: Wrap(
                children: [
                  Text("next_question".tr()),
                ],
              ),
              style: TextButton.styleFrom(
                primary: Colors.orange,
              ),
            ),
          if (!hasChosenAnswer)
            TextButton(
              onPressed: () {
                if (isCheckingAnswer) {
                  return;
                }

                onSkip();
              },
              child: Wrap(
                children: [
                  Text("skip".tr()),
                ],
              ),
              style: TextButton.styleFrom(
                primary: Colors.orange,
              ),
            ),
          TextButton(
            onPressed: () {
              if (isCheckingAnswer) {
                return;
              }

              onQuit();
            },
            child: Wrap(
              children: [
                Text("quit".tr()),
              ],
            ),
            style: TextButton.styleFrom(
              primary: Colors.pink,
            ),
          ),
        ],
      ),
    );
  }
}
