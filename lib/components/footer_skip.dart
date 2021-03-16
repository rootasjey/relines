import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class FooterSkip extends StatelessWidget {
  final VoidCallback onSkipQuestion;

  const FooterSkip({
    Key key,
    @required this.onSkipQuestion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
      ),
      child: TextButton(
        onPressed: onSkipQuestion,
        child: Text(
          "skip_full_msg".tr(),
        ),
      ),
    );
  }
}
