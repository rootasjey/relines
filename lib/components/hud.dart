import 'package:flutter/material.dart';
import 'package:relines/state/colors.dart';
import 'package:unicons/unicons.dart';

class Hud extends StatelessWidget {
  final bool isVisible;
  final int score;
  final int maxQuestions;
  final int currentQuestion;
  final VoidCallback onQuit;
  final VoidCallback onSkip;

  const Hud({
    Key key,
    this.onQuit,
    this.onSkip,
    @required this.score,
    @required this.maxQuestions,
    @required this.currentQuestion,
    this.isVisible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return Container();
    }

    return Container(
      width: 180.0,
      child: Card(
        elevation: 2.0,
        color: stateColors.tileBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
          side: BorderSide(
            color: stateColors.primary,
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
                        Text("Quit"),
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
                        Text("Skip"),
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
    );
  }
}
