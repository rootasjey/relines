import 'package:flutter/material.dart';
import 'package:relines/components/answer_picker.dart';
import 'package:relines/components/answer_result.dart';
import 'package:relines/components/checking_answer.dart';
import 'package:relines/components/fade_in_y.dart';
import 'package:relines/components/footer_skip.dart';
import 'package:relines/components/question_caption.dart';
import 'package:relines/components/quote_question.dart';
import 'package:relines/components/rules.dart';
import 'package:relines/types/game_answer_response.dart';
import 'package:relines/types/game_question_response.dart';
import 'package:supercharged/supercharged.dart';

class Playing extends StatelessWidget {
  final bool isCheckingAnswer;
  final bool isCurrentQuestionCompleted;

  final Color accentColor;

  final GameAnswerResponse answerResponse;
  final GameQuestionResponse questionResponse;

  final int currentQuestionIndex;
  final int maxQuestionsCount;

  final String quoteName;
  final String questionType;
  final String selectedId;

  final VoidCallback onNextQuestion;
  final VoidCallback onQuit;
  final VoidCallback onSkipQuestion;
  final void Function(String) onPickAnswer;

  const Playing({
    Key key,
    @required this.isCheckingAnswer,
    @required this.isCurrentQuestionCompleted,
    @required this.accentColor,
    @required this.answerResponse,
    @required this.questionResponse,
    @required this.currentQuestionIndex,
    @required this.maxQuestionsCount,
    @required this.quoteName,
    @required this.questionType,
    @required this.selectedId,
    @required this.onNextQuestion,
    @required this.onQuit,
    @required this.onSkipQuestion,
    @required this.onPickAnswer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Padding(
          padding: const EdgeInsets.all(80.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              children: [
                CheckingAnswer(isCheckingAnswer: isCheckingAnswer),
                AnswerResult(
                  isCurrentQuestionCompleted: isCurrentQuestionCompleted,
                  currentQuestionIndex: currentQuestionIndex,
                  maxQuestionsCount: maxQuestionsCount,
                  answerResponse: answerResponse,
                  onNextQuestion: onNextQuestion,
                  onQuit: onQuit,
                ),
                FadeInY(
                  beginY: 20.0,
                  delay: 100.milliseconds,
                  child: QuoteQuestion(
                    quoteName: quoteName,
                    accentColor: accentColor,
                  ),
                ),
                FadeInY(
                  beginY: 20.0,
                  delay: 300.milliseconds,
                  child: QuestionCaption(
                    questionType: questionType,
                  ),
                ),
                FadeInY(
                  beginY: 20.0,
                  delay: 600.milliseconds,
                  child: AnswerPicker(
                    questionType: questionType,
                    questionResponse: questionResponse,
                    onPickAnswer: onPickAnswer,
                    selectedId: selectedId,
                  ),
                ),
                FadeInY(
                  beginY: 20.0,
                  delay: 900.milliseconds,
                  child: FooterSkip(
                    onSkipQuestion: onSkipQuestion,
                  ),
                ),
                FadeInY(
                  beginY: 20.0,
                  delay: 1200.milliseconds,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 200.0),
                    child: Rules(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
