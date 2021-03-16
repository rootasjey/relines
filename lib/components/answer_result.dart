import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:relines/state/colors.dart';
import 'package:relines/types/game_answer_response.dart';
import 'package:unicons/unicons.dart';

class AnswerResult extends StatelessWidget {
  final VoidCallback onQuit;
  final VoidCallback onNextQuestion;
  final bool isCurrentQuestionCompleted;
  final int currentQuestionIndex;
  final int maxQuestionsCount;
  final GameAnswerResponse answerResponse;

  const AnswerResult({
    Key key,
    @required this.onQuit,
    @required this.onNextQuestion,
    @required this.isCurrentQuestionCompleted,
    @required this.currentQuestionIndex,
    @required this.maxQuestionsCount,
    @required this.answerResponse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isCurrentQuestionCompleted) {
      return Container();
    }

    Widget textMessageWidget = Text("");

    if (answerResponse.isCorrect) {
      textMessageWidget = Wrap(
        spacing: 10.0,
        children: [
          Icon(
            UniconsLine.grin,
            color: stateColors.primary,
          ),
          Text(
            "answer_correct".tr(),
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          Icon(
            UniconsLine.grin,
            color: stateColors.primary,
          ),
        ],
      );
    } else {
      textMessageWidget = Wrap(
        children: [
          Icon(
            UniconsLine.meh,
            color: stateColors.primary,
          ),
          RichText(
            text: TextSpan(
              text: "answer_wrong".tr(),
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
                color: stateColors.foreground,
              ),
              children: [
                TextSpan(
                  text: answerResponse.correction.name,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Container(
      width: 600.0,
      padding: const EdgeInsets.only(bottom: 40.0),
      child: Card(
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: textMessageWidget,
              ),
              Wrap(
                spacing: 20.0,
                children: [
                  OutlinedButton(
                    onPressed: onQuit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Text("quit".tr()),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onNextQuestion,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentQuestionIndex >= maxQuestionsCount
                                ? "see_results".tr()
                                : "next_question".tr(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(UniconsLine.arrow_right),
                          ),
                        ],
                      ),
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
