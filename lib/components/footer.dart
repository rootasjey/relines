import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:relines/components/circle_button.dart';
import 'package:relines/router/app_router.gr.dart';
import 'package:relines/state/colors.dart';
import 'package:relines/state/user.dart';
import 'package:relines/utils/constants.dart';
import 'package:relines/utils/fonts.dart';
import 'package:relines/utils/snack.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class Footer extends StatefulWidget {
  final ScrollController pageScrollController;
  final bool closeModalOnNav;
  final bool autoNavToHome;

  Footer({
    this.autoNavToHome = true,
    this.pageScrollController,
    this.closeModalOnNav = false,
  });

  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return SliverList(
        delegate: SliverChildListDelegate.fixed([
          footerDesktop(),
        ]),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(
        bottom: 400.0,
        left: 32.0,
        right: 24.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          footerMobile(),
        ]),
      ),
    );
  }

  Widget footerDesktop() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 60.0,
        vertical: 90.0,
      ),
      foregroundDecoration: BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, 0.1),
      ),
      child: Wrap(
        runSpacing: 80.0,
        alignment: WrapAlignment.spaceAround,
        children: <Widget>[
          apps(),
          developers(),
          resourcesLinks(),
        ],
      ),
    );
  }

  Widget footerMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            primary: stateColors.accent,
          ),
          onPressed: () {
            launch(
              "https://github.com/rootasjey/relines/"
              "issues",
            );
          },
          icon: Icon(UniconsLine.bug),
          label: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 12.0,
            ),
            child: Text("report_bug".tr()),
          ),
        ),
        Opacity(
          opacity: 0.6,
          child: Text(
            "v${Constants.appVersion}",
            style: FontsUtils.mainStyle(
              fontSize: 20.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 80.0),
          child: Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: [
              CircleButton(
                tooltip: "GitHub",
                icon: Icon(UniconsLine.github_alt),
                onTap: () {
                  launch(Constants.githubUrl);
                },
              ),
              CircleButton(
                tooltip: "about".tr(),
                onTap: () {
                  context.router.push(AboutRoute());
                },
                icon: Icon(UniconsLine.question),
              ),
              CircleButton(
                tooltip: "contact".tr(),
                onTap: () {
                  context.router.push(ContactRoute());
                },
                icon: Icon(Icons.sms_outlined),
              ),
              CircleButton(
                tooltip: "tos".tr(),
                onTap: () {
                  context.router.push(TosRoute());
                },
                icon: Icon(Icons.privacy_tip_outlined),
              ),
              CircleButton(
                tooltip: "settings".tr(),
                onTap: () {
                  context.router.push(SettingsRoute(showAppBar: true));
                },
                icon: Icon(UniconsLine.setting),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget apps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            bottom: 30.0,
            left: 4.0,
          ),
          child: Opacity(
            opacity: 0.5,
            child: Text(
              'apps'.tr().toUpperCase(),
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
        ),
        TextButton.icon(
            onPressed: () => launch(Constants.webAppUrl),
            icon: Icon(UniconsLine.globe),
            label: Text('Web'),
            style: TextButton.styleFrom(
              primary: Colors.deepPurple,
            )),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: TextButton.icon(
              onPressed: () => launch(Constants.playStoreUrl),
              icon: Icon(UniconsLine.android),
              label: Text('Android'),
              style: TextButton.styleFrom(
                primary: Colors.green,
              )),
        ),
        TextButton.icon(
          onPressed: () => launch(Constants.appStoreUrl),
          icon: Icon(UniconsLine.store),
          label: Text('iOS'),
        ),
      ],
    );
  }

  Widget basicButtonLink({Function onTap, @required String textValue}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 6.0,
        ),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
            // side: BorderSide(),
          ),
        ),
        child: Opacity(
          opacity: onTap != null ? 0.7 : 0.3,
          child: Text(
            textValue,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget developers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            bottom: 30.0,
            left: 10.0,
          ),
          child: Opacity(
            opacity: 0.5,
            child: Text(
              'developers'.tr().toUpperCase(),
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
        ),
        basicButtonLink(
          textValue: 'dashboard'.tr(),
          onTap: () => launch(Constants.developersPortal),
        ),
        basicButtonLink(
          textValue: 'Documentation',
        ),
        basicButtonLink(
          textValue: 'API References',
        ),
        basicButtonLink(
          textValue: 'API Status',
        ),
        basicButtonLink(
          textValue: 'GitHub',
          onTap: () async {
            onBeforeNav();
            await launch(Constants.githubUrl);
          },
        ),
      ],
    );
  }

  Widget resourcesLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            bottom: 30.0,
            left: 10.0,
          ),
          child: Opacity(
            opacity: 0.5,
            child: Text(
              'resources'.tr().toUpperCase(),
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
        ),
        basicButtonLink(
          textValue: 'about'.tr(),
          onTap: () {
            onBeforeNav();
            context.router.root.push(AboutRoute());
          },
        ),
        basicButtonLink(
          textValue: 'contact'.tr(),
          onTap: () {
            onBeforeNav();
            context.router.root.push(ContactRoute());
          },
        ),
        basicButtonLink(
          textValue: 'tos'.tr(),
          onTap: () {
            onBeforeNav();
            context.router.root.push(TosRoute());
          },
        ),
      ],
    );
  }

  void notifyLangSuccess() {
    if (widget.pageScrollController != null) {
      widget.pageScrollController.animateTo(
        0.0,
        duration: Duration(seconds: 1),
        curve: Curves.easeOut,
      );
    } else if (widget.autoNavToHome) {
      context.router.root.navigate(HomeRoute());
    }

    Snack.s(
      context: context,
      message: 'Your language has been successfully updated.',
    );
  }

  void onBeforeNav() {
    if (widget.closeModalOnNav) {
      context.router.pop();
    }
  }

  void updateUserAccountLang() async {
    final userAuth = stateUser.userAuth;

    if (userAuth == null) {
      notifyLangSuccess();
      return;
    }
  }
}
