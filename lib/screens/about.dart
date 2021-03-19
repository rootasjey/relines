import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:relines/components/credit_item.dart';
import 'package:relines/components/desktop_app_bar.dart';
import 'package:relines/components/footer.dart';
import 'package:relines/components/image_hero.dart';
import 'package:relines/router/app_router.gr.dart';
import 'package:relines/state/colors.dart';
import 'package:relines/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supercharged/supercharged.dart';
import 'package:easy_localization/easy_localization.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  bool isFabVisible = false;

  final captionOpacity = 0.6;

  final maxWidth = 600.0;

  final _pageScrollController = ScrollController();

  final paragraphOpacity = 0.6;
  final paragraphStyle = TextStyle(
    fontSize: 18.0,
    height: 1.5,
  );

  final titleOpacity = 0.9;
  final titleStyle = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context) {
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
      body: Overlay(
        initialEntries: [
          OverlayEntry(builder: (context) {
            return NotificationListener<ScrollNotification>(
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
                slivers: <Widget>[
                  DesktopAppBar(
                    title: 'about'.tr(),
                    automaticallyImplyLeading: true,
                    showUserMenu: false,
                    onNavBack: context.router.pop,
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      bottom: 200.0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Column(
                          children: <Widget>[
                            appIconImage(),
                            otherLinks(),
                            whatIs(),
                            whoIs(),
                            creditsSection(),
                          ],
                        ),
                      ]),
                    ),
                  ),
                  if (kIsWeb && MediaQuery.of(context).size.width > 700.0)
                    SliverList(
                      delegate: SliverChildListDelegate([
                        Footer(),
                      ]),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget appIconImage() {
    final size = MediaQuery.of(context).size.width < 500.0 ? 280.0 : 380.0;

    return Container(
      padding: const EdgeInsets.only(
        top: 20.0,
        bottom: 40.0,
      ),
      width: maxWidth,
      child: Column(
        children: [
          Center(
            child: OpenContainer(
              closedColor: Colors.transparent,
              closedElevation: 0.0,
              closedBuilder: (context, openContainer) {
                return Container(
                  width: size,
                  height: size,
                  child: Ink.image(
                    height: size,
                    width: size,
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/app_icon/512.png'),
                    child: InkWell(
                      onTap: openContainer,
                    ),
                  ),
                );
              },
              openBuilder: (context, callback) {
                return ImageHero(
                  imageProvider: AssetImage('assets/images/app_icon/512.png'),
                );
              },
            ),
          ),
          Center(
            child: TextButton(
              onPressed: null,
              child: Opacity(
                opacity: captionOpacity,
                child: Text('App large icon'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget creditsSection() {
    return SizedBox(
      width: maxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Opacity(
            opacity: titleOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 120.0, bottom: 30.0),
              child: Text(
                'CREDITS',
                style: titleStyle,
              ),
            ),
          ),
          CreditItem(
            textValue: 'Icons by Unicons',
            onTap: () => launch('https://iconscout.com/unicons'),
            iconData: UniconsLine.palette,
            hoverColor: stateColors.primary,
          ),
          CreditItem(
            textValue: 'Mobile app screenshots created with AppMockUp',
            onTap: () => launch('https://app-mockup.com/'),
            iconData: UniconsLine.mobile_android,
            hoverColor: stateColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget otherLinks() {
    return SizedBox(
      width: maxWidth / 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Opacity(
              opacity: 0.7,
              child: Text(
                Constants.appVersion,
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Changelog'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () => context.router.push(ChangelogRoute()),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Terms of service'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () => context.router.push(TosRoute()),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('GitHub'),
              trailing: Icon(Icons.open_in_new),
              onTap: () => launch(Constants.githubUrl),
            ),
          ),
        ],
      ),
    );
  }

  Widget whatIs() {
    return Container(
      width: maxWidth,
      padding: const EdgeInsets.only(
        top: 40.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: Opacity(
              opacity: titleOpacity,
              child: Text(
                'THE CONCEPT',
                style: titleStyle,
              ),
            ),
          ),
          Opacity(
            opacity: paragraphOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: Text(
                'about_concept'.tr(),
                style: paragraphStyle,
              ),
            ),
          ),
          Opacity(
            opacity: paragraphOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: Text(
                'about_concept_2'.tr(),
                style: paragraphStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget whoIs() {
    return SizedBox(
      width: maxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Opacity(
            opacity: titleOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 120.0),
              child: Text(
                'the_author'.tr(),
                style: titleStyle,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60.0),
              child: OpenContainer(
                closedColor: Colors.transparent,
                closedElevation: 0.0,
                closedBuilder: (context, openContainer) {
                  return Material(
                    elevation: 1.0,
                    shape: CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    color: Colors.transparent,
                    child: Ink.image(
                      image: AssetImage('assets/images/jeje.jpg'),
                      fit: BoxFit.cover,
                      width: 200.0,
                      height: 200.0,
                      child: InkWell(
                        onTap: openContainer,
                      ),
                    ),
                  );
                },
                openBuilder: (context, callback) {
                  return ImageHero(
                    imageProvider: AssetImage('assets/images/jeje.jpg'),
                  );
                },
              ),
            ),
          ),
          Opacity(
            opacity: paragraphOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Text(
                'about_me_1'.tr(),
                style: paragraphStyle,
              ),
            ),
          ),
          Opacity(
            opacity: paragraphOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                "about_me_2".tr(),
                style: paragraphStyle,
              ),
            ),
          ),
          Opacity(
            opacity: paragraphOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                "about_me_3".tr(),
                style: paragraphStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
