import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:relines/utils/constants.dart';
import 'package:relines/utils/snack.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareScore extends StatelessWidget {
  final int score;
  final int correctAnswers;
  final int maxQuestionsCount;

  const ShareScore({
    Key key,
    @required this.score,
    @required this.correctAnswers,
    @required this.maxQuestionsCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60.0),
      child: Wrap(
        spacing: 24.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          TextButton.icon(
            onPressed: () {
              launch(
                "share_score_on_twitter_msg".tr(
                  namedArgs: {
                    "baseUrl": Constants.baseTwitterShareUrl,
                    "score": score.toString(),
                    "correctAnswers": correctAnswers.toString(),
                    "maxQuestions": maxQuestionsCount.toString(),
                    "suffix1": Constants.twitterShareHashtags,
                    "suffix2": Constants.twitterShareUrl,
                  },
                ),
              );
            },
            icon: Icon(UniconsLine.twitter),
            label: Text("share_on_twitter".tr()),
          ),
          IconButton(
            tooltip: "copy_result_msg".tr(),
            onPressed: () {
              Clipboard.setData(
                ClipboardData(
                  text: "share_score_text_msg".tr(
                    namedArgs: {
                      "score": score.toString(),
                      "correctAnswers": correctAnswers.toString(),
                      "maxQuestions": maxQuestionsCount.toString(),
                      "url": Constants.webAppUrl,
                    },
                  ),
                ),
              );

              Snack.i(
                context: context,
                message: "copy_link_success".tr(),
              );
            },
            icon: Icon(UniconsLine.link),
          ),
        ],
      ),
    );
  }
}
