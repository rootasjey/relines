import 'package:flutter/material.dart';
import 'package:relines/components/fade_in_x.dart';
import 'package:relines/components/image_card.dart';
import 'package:relines/types/enums.dart';
import 'package:relines/types/game_question_response.dart';
import 'package:relines/utils/constants.dart';

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
      return authorsRow(context);
    }

    return referencesRow(context);
  }

  Widget authorsRow(BuildContext context) {
    int index = 0;

    if (questionResponse.authorProposals == null) {
      return Container();
    }

    final size = MediaQuery.of(context).size;
    double height = 320.0;
    double width = 240.0;

    if (size.width < Constants.maxMobileWidth) {
      height = 150.0;
      width = 360.0;
    }

    final children = questionResponse.authorProposals.values.map(
      (proposal) {
        index++;
        return FadeInX(
          beginX: 20.0,
          delay: Duration(milliseconds: 200 * index),
          child: ImageCard(
            name: proposal.name,
            height: height,
            width: width,
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
    ).toList();

    if (size.width < Constants.maxMobileWidth) {
      return Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Column(
          children: children,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget referencesRow(BuildContext context) {
    int index = 0;

    if (questionResponse.referenceProposals == null) {
      return Container();
    }

    final size = MediaQuery.of(context).size;
    double height = 320.0;
    double width = 240.0;

    if (size.width < Constants.maxMobileWidth) {
      height = 150.0;
      width = 360.0;
    }

    final children = questionResponse.referenceProposals.values.map(
      (proposal) {
        index++;

        return FadeInX(
          beginX: 20.0,
          delay: Duration(milliseconds: 200 * index),
          child: ImageCard(
            name: proposal.name,
            height: height,
            width: width,
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
    ).toList();

    if (size.width < Constants.maxMobileWidth) {
      return Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Column(
          children: children,
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}
