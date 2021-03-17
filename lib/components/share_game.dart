import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:relines/state/colors.dart';
import 'package:relines/utils/constants.dart';
import 'package:relines/utils/snack.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24.0,
      children: [
        TextButton.icon(
          style: TextButton.styleFrom(
            primary: stateColors.accent,
          ),
          onPressed: () {
            launch(
              "share_link_on_twitter_msg".tr(
                args: [
                  Constants.baseTwitterShareUrl,
                  Constants.twitterShareHashtags,
                  Constants.twitterShareUrl,
                ],
              ),
            );
          },
          icon: Icon(UniconsLine.twitter),
          label: Text("share_on_twitter".tr()),
        ),
        IconButton(
          tooltip: "copy_link".tr(),
          onPressed: () {
            Clipboard.setData(
              ClipboardData(text: Constants.webAppUrl),
            );

            Snack.i(
              context: context,
              message: "copy_link_success".tr(),
            );
          },
          icon: Icon(UniconsLine.link),
        ),
      ],
    );
  }
}
