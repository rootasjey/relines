import 'package:auto_route/auto_route.dart';
import 'package:relines/components/desktop_app_bar.dart';
import 'package:relines/state/colors.dart';
import 'package:relines/utils/constants.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supercharged/supercharged.dart';

/// Terms Of Service.
class Tos extends StatefulWidget {
  @override
  _TosState createState() => _TosState();
}

class _TosState extends State<Tos> {
  bool isFabVisible = false;

  final _pageScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    bool showUserMenu = true;
    double horPadding = 80.0;

    if (width < Constants.maxMobileWidth) {
      showUserMenu = false;
      horPadding = 20.0;
    }

    return Scaffold(
      floatingActionButton: isFabVisible
          ? FloatingActionButton(
              onPressed: () {
                _pageScrollController.animateTo(
                  0.0,
                  duration: 500.milliseconds,
                  curve: Curves.easeOut,
                );
              },
              backgroundColor: stateColors.accent,
              foregroundColor: Colors.white,
              child: Icon(Icons.arrow_upward),
            )
          : null,
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollNotif) {
          // FAB visibility
          if (scrollNotif.metrics.pixels < 50 && isFabVisible) {
            setState(() => isFabVisible = false);
          } else if (scrollNotif.metrics.pixels > 50 && !isFabVisible) {
            setState(() => isFabVisible = true);
          }
          return false;
        },
        child: CustomScrollView(
          controller: _pageScrollController,
          slivers: [
            DesktopAppBar(
              title: "Privacy Terms",
              automaticallyImplyLeading: true,
              showUserMenu: showUserMenu,
              onNavBack: context.router.pop,
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: horPadding,
                vertical: 60.0,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  Column(
                    children: [
                      SizedBox(
                        width: 600.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            termsBlock(),
                            cookiesBlock(),
                            analyticsBlock(),
                            advertisingBlock(),
                            inAppPurchasesBlock(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cookiesBlock() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      titleBlock(
        text: 'COOKIES',
      ),
      textSuperBlock(
        text:
            'The application does not use cookies neither for user preferences nor tracking with id advertising.',
      ),
    ]);
  }

  Widget analyticsBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleBlock(
          text: 'ANALYTICS',
        ),
        textSuperBlock(
          text:
              'The web & mobile apps collect usage data to improve the apps & services. However, personal data is never shared or sell to third parties.',
        ),
      ],
    );
  }

  Widget advertisingBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleBlock(
          text: 'ADVERTISING',
        ),
        textSuperBlock(
          text:
              'The web & mobile apps may contain advertising to generate revenues. Advertisers may collect additional data on your navigation and preferences.',
        ),
      ],
    );
  }

  Widget inAppPurchasesBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleBlock(
          text: 'IN-APP PURCHASES',
        ),
        textSuperBlock(
          text:
              'The apps contain in-app purchases which offer additional features.',
        ),
      ],
    );
  }

  Widget termsBlock() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Text(
              "Terms of service",
              style: TextStyle(
                fontSize: 50.0,
                color: stateColors.accent,
              ),
            ),
          ),
          textSuperBlock(
            text:
                "Your privacy is important to us. It is Jeremie Codes' policy to respect your privacy regarding any information we may collect from you across our website, fig.style, and other sites we own and operate including mobile apps.",
          ),
          textSuperBlock(
            text:
                "We only ask for personal information when we truly need it to provide a service to you. We collect it by fair and lawful means, with your knowledge and consent. We also let you know why we’re collecting it and how it will be used.",
          ),
          textSuperBlock(
            text:
                "We only retain collected information for as long as necessary to provide you with your requested service. What data we store, we’ll protect within commercially acceptable means to prevent loss and theft, as well as unauthorized access, disclosure, copying, use or modification.",
          ),
          textSuperBlock(
            text:
                "We don’t share any personally identifying information publicly or with third-parties, except when required to by law.",
          ),
          textSuperBlock(
            text:
                "Our website may link to external sites that are not operated by us. Please be aware that we have no control over the content and practices of these sites, and cannot accept responsibility or liability for their respective privacy policies.",
          ),
          textSuperBlock(
            text:
                "You are free to refuse our request for your personal information, with the understanding that we may be unable to provide you with some of your desired services.",
          ),
          textSuperBlock(
            text:
                "Your continued use of our website will be regarded as acceptance of our practices around privacy and personal information. If you have any questions about how we handle user data and personal information, feel free to contact us.",
          ),
          textSuperBlock(
            text: "This policy is effective as of 1 May 2020.",
          ),
          Text.rich(
            TextSpan(
              text: "Privacy Policy created with GetTerms.",
              style: TextStyle(
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launch("https://getterms.io/");
                },
            ),
          ),
        ],
      ),
    );
  }

  Widget titleBlock({@required String text}) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0, bottom: 16.0),
      child: Opacity(
        opacity: 1.0,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: stateColors.primary,
          ),
        ),
      ),
    );
  }

  Widget textSuperBlock({@required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Opacity(
        opacity: 0.8,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }
}
