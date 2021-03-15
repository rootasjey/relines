import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          onPressed: () {
            launch("${Constants.baseTwitterShareUrl}This game is fun!"
                "${Constants.twitterShareHashtags}"
                "&url=https://dis.fig.style");
          },
          icon: Icon(UniconsLine.twitter),
          label: Text("Share on Twitter"),
        ),
        IconButton(
          tooltip: "Copy link",
          onPressed: () {
            Clipboard.setData(
              ClipboardData(text: Constants.disUrl),
            );

            Snack.i(
              context: context,
              message: "Link successfully copied!",
            );
          },
          icon: Icon(UniconsLine.link),
        ),
      ],
    );
  }
}
