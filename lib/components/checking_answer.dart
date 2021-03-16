import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:relines/components/animated_app_icon.dart';

class CheckingAnswer extends StatelessWidget {
  final bool isCheckingAnswer;

  const CheckingAnswer({
    Key key,
    @required this.isCheckingAnswer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isCheckingAnswer) {
      return Container();
    }

    return Wrap(
      spacing: 16.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          "checking_answer".tr(),
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
        AnimatedAppIcon(size: 70.0),
      ],
    );
  }
}
