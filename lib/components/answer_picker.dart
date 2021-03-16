import 'package:flutter/material.dart';
import 'package:relines/components/fade_in_x.dart';
import 'package:relines/components/image_card.dart';
import 'package:relines/types/enums.dart';
import 'package:relines/types/game_question_response.dart';

class AnswerPicker extends StatelessWidget {
  final String questionType;
  final String selectedId;
  final GameQuestionResponse questionResponse;
  final void Function(String) onPickAnswer;

  const AnswerPicker({
    Key key,
    @required this.questionType,
    @required this.questionResponse,
    @required this.selectedId,
    @required this.onPickAnswer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (questionType == 'author') {
      return authorsRow();
    }

    return referencesRow();
  }

  Widget authorsRow() {
    int index = 0;

    if (questionResponse.authorProposals == null) {
      return Container();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: questionResponse.authorProposals.values.map(
        (proposal) {
          index++;
          return FadeInX(
            beginX: 20.0,
            delay: Duration(milliseconds: 200 * index),
            child: ImageCard(
              name: proposal.name,
              imageUrl: proposal.urls.image,
              selected: selectedId == proposal.id,
              type: ImageCardType.extended,
              onTap: () {
                if (onPickAnswer != null) {
                  onPickAnswer(proposal.id);
                }
              },
            ),
          );
        },
      ).toList(),
    );
  }

  Widget referencesRow() {
    int index = 0;

    if (questionResponse.referenceProposals == null) {
      return Container();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: questionResponse.referenceProposals.values.map(
        (proposal) {
          index++;

          return FadeInX(
            beginX: 20.0,
            delay: Duration(milliseconds: 200 * index),
            child: ImageCard(
              name: proposal.name,
              imageUrl: proposal.urls.image,
              selected: selectedId == proposal.id,
              type: ImageCardType.extended,
              onTap: () {
                if (onPickAnswer != null) {
                  onPickAnswer(proposal.id);
                }
              },
            ),
          );
        },
      ).toList(),
    );
  }
}
