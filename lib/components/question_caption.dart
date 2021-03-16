import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class QuestionCaption extends StatelessWidget {
  final String questionType;

  const QuestionCaption({
    Key key,
    @required this.questionType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String helpText = questionType == 'author'
        ? "question_author".tr()
        : "question_reference".tr();

    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        bottom: 32.0,
      ),
      child: Opacity(
        opacity: 0.5,
        child: Text(
          helpText,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
