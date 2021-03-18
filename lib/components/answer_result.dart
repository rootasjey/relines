import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:relines/state/colors.dart';
import 'package:relines/types/game_answer_response.dart';
import 'package:relines/utils/constants.dart';
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

    if (MediaQuery.of(context).size.width < Constants.maxMobileWidth) {
      return mobileLayout();
    }

    return desktopLayout();
  }

  Widget desktopLayout() {
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
                child: answerResponse.isCorrect
                    ? correctTextWidget()
                    : wrongTextWidget(),
              ),
              Wrap(
                spacing: 20.0,
                children: [
                  OutlinedButton(
                    onPressed: onQuit,
                    style: OutlinedButton.styleFrom(
                      primary: stateColors.accent,
                    ),
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
                    style: ElevatedButton.styleFrom(
                      primary: stateColors.accent,
                    ),
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

  Widget mobileLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 32.0,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Divider(
              height: 40.0,
              color: Colors.black12,
              thickness: 2.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              bottom: 16.0,
            ),
            child: answerResponse.isCorrect
                ? correctTextWidget()
                : wrongTextWidget(),
          ),
          Wrap(
            spacing: 20.0,
            alignment: WrapAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: onQuit,
                style: OutlinedButton.styleFrom(
                  primary: stateColors.accent,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  child: Text("quit".tr()),
                ),
              ),
              ElevatedButton(
                onPressed: onNextQuestion,
                style: ElevatedButton.styleFrom(
                  primary: stateColors.accent,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
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
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
          ),
          Divider(
            color: Colors.black12,
            thickness: 2.0,
          ),
        ],
      ),
    );
  }

  Widget correctTextWidget() {
    return Wrap(
      spacing: 10.0,
      children: [
        Icon(
          UniconsLine.grin,
          color: stateColors.accent,
        ),
        Text(
          "answer_correct".tr(),
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w400,
            color: stateColors.foreground.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget wrongTextWidget() {
    return Wrap(
      children: [
        Icon(
          UniconsLine.meh,
          color: stateColors.accent,
        ),
        RichText(
          text: TextSpan(
            text: "answer_wrong".tr(),
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w400,
              color: stateColors.foreground.withOpacity(0.5),
            ),
            children: [
              TextSpan(
                text: answerResponse.correction.name,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
