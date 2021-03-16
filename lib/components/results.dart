import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:relines/components/game_title.dart';
import 'package:relines/components/share_score.dart';
import 'package:relines/state/colors.dart';
import 'package:unicons/unicons.dart';

class Results extends StatelessWidget {
  final VoidCallback initGame;
  final VoidCallback onReturnHome;
  final int score;
  final int correctAnswers;
  final int maxQuestionsCount;

  const Results({
    Key key,
    @required this.initGame,
    @required this.onReturnHome,
    @required this.score,
    @required this.correctAnswers,
    @required this.maxQuestionsCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Container(
          width: 700.0,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(80.0),
          child: Column(
            children: [
              GameTitle(),
              thankYou(),
              actions(),
              scoreCard(),
              ShareScore(
                score: score,
                correctAnswers: correctAnswers,
                maxQuestionsCount: maxQuestionsCount,
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget actions() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Wrap(
        spacing: 12.0,
        children: [
          TextButton.icon(
            onPressed: onReturnHome,
            icon: Icon(UniconsLine.home),
            label: Text("return_home".tr()),
            style: TextButton.styleFrom(
              primary: stateColors.foreground.withOpacity(0.5),
            ),
          ),
          TextButton.icon(
            onPressed: initGame,
            icon: Icon(UniconsLine.refresh),
            label: Text("play_again".tr()),
            style: TextButton.styleFrom(
              primary: stateColors.foreground.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget scoreCard() {
    return Container(
      width: 500.0,
      padding: const EdgeInsets.only(top: 60.0),
      child: Card(
        elevation: 4.0,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              scoreCardTitle(),
              scoreCardMessage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget scoreCardMessage() {
    return RichText(
      text: TextSpan(
        text: "result_msg_1".tr(),
        children: [
          TextSpan(
            text: "result_msg_2".tr(
              args: [
                score.toString(),
              ],
            ),
            style: TextStyle(
              fontSize: 24.0,
              color: Colors.yellow.shade800,
            ),
          ),
          TextSpan(
            text: "result_msg_3".tr(),
          ),
          TextSpan(
            text: "result_msg_4".tr(
              args: [
                correctAnswers.toString(),
              ],
            ),
            style: TextStyle(
              fontSize: 24.0,
              color: Colors.yellow.shade800,
            ),
          ),
          TextSpan(
            text: "result_msg_5".tr(),
          ),
          TextSpan(
            text: "result_msg_6".tr(
              args: [
                maxQuestionsCount.toString(),
              ],
            ),
            style: TextStyle(
              fontSize: 24.0,
              color: Colors.yellow.shade800,
            ),
          ),
        ],
        style: TextStyle(
          fontSize: 24.0,
          color: stateColors.foreground.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget scoreCardTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Wrap(
        spacing: 8.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(
            UniconsLine.award,
            color: Colors.yellow.shade800,
          ),
          Text(
            "result".tr(),
            style: TextStyle(
              color: Colors.yellow.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget thankYou() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Opacity(
          opacity: 0.6,
          child: Text(
            "thank_you_playing".tr(),
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w100,
              decoration: TextDecoration.underline,
              decorationColor: stateColors.foreground.withOpacity(0.4),
              decorationStyle: TextDecorationStyle.solid,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Icon(
            UniconsLine.heart,
            color: Colors.pink,
          ),
        ),
      ],
    );
  }
}
