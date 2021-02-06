import 'dart:convert';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disfigstyle/components/animated_app_icon.dart';
import 'package:disfigstyle/components/desktop_app_bar.dart';
import 'package:disfigstyle/components/footer.dart';
import 'package:disfigstyle/router/app_router.gr.dart';
import 'package:disfigstyle/state/colors.dart';
import 'package:disfigstyle/types/author.dart';
import 'package:disfigstyle/types/quote.dart';
import 'package:disfigstyle/types/reference.dart';
import 'package:disfigstyle/utils/api_keys.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Author author;

  bool isLoadingQuotidian = false;
  bool isLoadingAuthorPropCard = false;
  bool isLoadingSearch = false;
  bool isFabVisible = false;

  Color _imageBackgroundColor = Colors.blue.shade800;

  final _scrollController = ScrollController();
  final quotesHeader = <Quote>[];
  final quotidianEndpoint = "https://api.fig.style/v1/quotidian";
  final searchQuotesEndpoint = "https://api.fig.style/v1/search/quotes?q=";
  final _searchInputFocusNode = FocusNode();

  Reference referenceHeader;

  String quotidianJson = '';
  String searchJson = '';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchQuotesHeader();
    fetchHeaderReference();
  }

  @override
  dispose() {
    _searchInputFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isFabVisible
          ? FloatingActionButton(
              foregroundColor: Colors.white,
              backgroundColor: stateColors.accent,
              child: Icon(Icons.arrow_upward),
              onPressed: () {
                _scrollController.animateTo(
                  0.0,
                  duration: Duration(seconds: 1),
                  curve: Curves.easeOut,
                );
              },
            )
          : null,
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollNotif) {
          if (scrollNotif.depth != 0) {
            return false;
          }

          // FAB visibility
          if (scrollNotif.metrics.pixels < 50 && isFabVisible) {
            setState(() => isFabVisible = false);
          } else if (scrollNotif.metrics.pixels > 50 && !isFabVisible) {
            setState(() => isFabVisible = true);
          }

          return false;
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            DesktopAppBar(
              padding: const EdgeInsets.only(left: 65.0),
              onTapIconHeader: () {
                _scrollController.animateTo(
                  0,
                  duration: 250.milliseconds,
                  curve: Curves.decelerate,
                );
              },
            ),
            header(),
            about(),
            features(),
            techStack(),
            plan(),
            footer(),
          ],
        ),
      ),
    );
  }

  Widget about() {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Container(
          color: stateColors.primary,
          width: 600.0,
          padding: const EdgeInsets.symmetric(
            vertical: 60.0,
            horizontal: 80.0,
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 40.0,
            children: [
              Text(
                "About us",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40.0,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(
                width: 400.0,
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    "Because, there wasn't any robust API "
                    "to consume diversified quotes, we created one"
                    " easy to use, with a generous plan, "
                    "and with an open sourced code.",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget authorPropCard() {
    final content = <Widget>[];

    if (isLoadingAuthorPropCard) {
      content.add(AnimatedAppIcon(size: 50.0));
    } else if (author == null) {
      content.add(
        Icon(UniconsLine.question),
      );
    } else {
      content.addAll([
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Opacity(
            opacity: 0.6,
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                text: "name: ",
                style: TextStyle(
                  color: stateColors.foreground,
                  fontWeight: FontWeight.w300,
                ),
                children: [
                  TextSpan(
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                    text: author.name,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (author.job != null && author.job.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Opacity(
              opacity: 0.6,
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  text: "job: ",
                  style: TextStyle(
                    color: stateColors.foreground,
                    fontWeight: FontWeight.w300,
                  ),
                  children: [
                    TextSpan(
                      text: author.job,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (author.urls.wikipedia != null && author.urls.wikipedia.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Opacity(
              opacity: 0.6,
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  text: "wikipedia url",
                  style: TextStyle(
                    color: stateColors.foreground,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w300,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => launch(author.urls.wikipedia),
                ),
              ),
            ),
          ),
        Opacity(
          opacity: 0.6,
          child: Text(
            "...",
            style: TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ]);
    }

    return SizedBox(
      width: 220.0,
      height: 150.0,
      child: Card(
        child: InkWell(
          onTap: fetchAuthorPropCard,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 8.0,
                  left: 8.0,
                  right: 8.0,
                ),
                child: Text(
                  "Author",
                  style: TextStyle(
                    color: Colors.pink,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Divider(
                thickness: 1.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: content,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cardFreePlan() {
    return Container(
      width: 400.0,
      padding: const EdgeInsets.all(20.0),
      child: Card(
        elevation: 0.0,
        color: stateColors.softBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(
            width: 2.0,
            color: stateColors.foreground.withOpacity(0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Free",
                style: TextStyle(
                  fontSize: 24.0,
                  color: stateColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              RichText(
                text: TextSpan(
                  text: "0€",
                  style: TextStyle(
                    fontSize: 60.0,
                    fontWeight: FontWeight.w600,
                    color: stateColors.foreground.withOpacity(0.8),
                  ),
                  children: [
                    TextSpan(
                      text: " /month",
                      style: TextStyle(
                        fontSize: 20.0,
                        color: stateColors.foreground.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 32.0,
                ),
                child: Opacity(
                  opacity: 0.5,
                  child: Text(
                    "Free plan is the perfect to start designing"
                    ", developing, and testing APIs.",
                  ),
                ),
              ),
              planCardFeature(title: "Query quote of the day"),
              planCardFeature(title: "Query quotes, authors and references"),
              planCardFeature(title: "Use search API"),
              planCardFeature(title: "API rates limit at 1k request per day"),
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: ElevatedButton(
                  onPressed: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Start free",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cardPremiumPlan() {
    return Container(
      width: 400.0,
      padding: const EdgeInsets.all(20.0),
      child: Card(
        elevation: 0.0,
        // color: Colors.blue,
        color: Colors.pink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Premium",
                style: TextStyle(
                  fontSize: 24.0,
                  color: stateColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              RichText(
                text: TextSpan(
                  text: "1€",
                  style: TextStyle(
                    fontSize: 60.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  children: [
                    TextSpan(
                      text: " / 5k requests",
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 32.0,
                ),
                child: Opacity(
                  opacity: 0.5,
                  child: Text(
                    "Pay as you go plan when you are ready to release"
                    " your app, while keeping an eye on your expenses.",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              planCardFeature(
                title: "Everything in free plan",
                titleColor: Colors.white,
              ),
              planCardFeature(
                title: "Personal support",
                titleColor: Colors.white,
              ),
              planCardFeature(
                title: "No API rates limit",
                titleColor: Colors.white,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: OutlinedButton(
                  onPressed: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Soon...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget easyToUseFeature() {
    return Container(
      width: 600.0,
      padding: const EdgeInsets.symmetric(
        vertical: 40.0,
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 40.0,
        children: [
          quotidianMiniPlayground(),
          SizedBox(
            width: 400.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                  opacity: 0.8,
                  child: Text(
                    "Easy to use",
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                  ),
                  child: Opacity(
                    opacity: 0.6,
                    child: Text(
                      "You can start to use the API right away "
                      "for simple usages. Create an account "
                      "to perform more advanced queries.",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget features() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        vertical: 60.0,
        horizontal: 80.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Padding(
            padding: const EdgeInsets.only(
              bottom: 40.0,
            ),
            child: Column(
              children: [
                Opacity(
                  opacity: 0.8,
                  child: Text(
                    "Features",
                    style: TextStyle(
                      fontSize: 70.0,
                      fontWeight: FontWeight.w900,
                      fontFamily: GoogleFonts.pacifico().fontFamily,
                    ),
                  ),
                ),
                Opacity(
                  opacity: 0.5,
                  child: Text(
                    "we crafted for you",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ],
            ),
          ),
          easyToUseFeature(),
          richDataFeature(),
          searchFeature(),
        ]),
      ),
    );
  }

  Widget footer() {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Footer(),
      ]),
    );
  }

  Widget header() {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Container(
          height: MediaQuery.of(context).size.height - 130.0,
          padding: const EdgeInsets.only(
            left: 80.0,
            right: 80.0,
            top: 100.0,
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              headerLeft(),
              headerRight(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: IconButton(
            onPressed: () {
              _scrollController.animateTo(
                MediaQuery.of(context).size.height * 1.5,
                curve: Curves.bounceOut,
                duration: 250.milliseconds,
              );
            },
            icon: Icon(UniconsLine.arrow_down),
          ),
        ),
      ]),
    );
  }

  Widget headerLeft() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Opacity(
          opacity: 0.8,
          child: RichText(
            text: TextSpan(
              text: "dev",
              style: TextStyle(
                fontSize: 80.0,
                color: stateColors.foreground,
                fontFamily: GoogleFonts.pacifico().fontFamily,
              ),
              children: [
                TextSpan(
                  text: ".",
                  style: TextStyle(
                    color: stateColors.secondary,
                  ),
                ),
                TextSpan(
                  text: "fig",
                ),
                TextSpan(
                  text: ".",
                  style: TextStyle(
                    color: stateColors.primary,
                  ),
                ),
                TextSpan(
                  text: "style",
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 8.0,
          ),
          child: Opacity(
            opacity: 0.5,
            child: Text(
              "Quotes for developers",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w200,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 60.0,
          ),
          child: Wrap(
            spacing: 20.0,
            children: [
              ElevatedButton(
                onPressed: () => context.router,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Get started",
                      ),
                      Icon(UniconsLine.arrow_right),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.router.push(AboutRoute()),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Read the docs",
                    style: TextStyle(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget headerRight() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        headerVerticalCard(),
        SizedBox(
          width: 300.0,
          child: Wrap(
            children: quotesHeader.map((quote) {
              return headerCard(quote);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget headerCard(Quote quote) {
    final size = 150.0;

    return SizedBox(
      width: size,
      height: size,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Opacity(
            opacity: 0.6,
            child: Text(
              quote.name,
            ),
          ),
        ),
      ),
    );
  }

  Widget headerVerticalCard() {
    if (referenceHeader == null) {
      return Container();
    }

    return Container(
      width: 180.0,
      height: 300.0,
      padding: const EdgeInsets.only(right: 20.0),
      child: Card(
        elevation: 4.0,
        child: Stack(
          children: [
            Stack(
              children: [
                verticalCardImage(),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Opacity(
                    opacity: 0.6,
                    child: Text(
                      referenceHeader.name,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget plan() {
    return SliverPadding(
      padding: const EdgeInsets.all(40.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Column(
            children: [
              Text(
                "Plan",
                style: TextStyle(
                  fontSize: 70.0,
                  fontFamily: GoogleFonts.pacifico().fontFamily,
                ),
              ),
              Opacity(
                opacity: 0.4,
                child: Text(
                  "Choose your plan. Start free. Pay as you go.",
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
              planCards(),
            ],
          ),
        ]),
      ),
    );
  }

  Widget planCards() {
    return Container(
      height: 600.0,
      padding: const EdgeInsets.all(40.0),
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: [
          cardFreePlan(),
          cardPremiumPlan(),
        ],
      ),
    );
  }

  Widget planCardFeature({String title, Color titleColor, Widget icon}) {
    if (icon == null) {
      icon = Icon(
        UniconsLine.check,
        color: stateColors.secondary,
      );
    }

    return Row(
      children: [
        icon,
        Padding(
          padding: const EdgeInsets.only(
            left: 12.0,
          ),
          child: Opacity(
            opacity: 0.8,
            child: titleColor != null
                ? Text(title, style: TextStyle(color: titleColor))
                : Text(title),
          ),
        ),
      ],
    );
  }

  Widget quotePropCard() {
    return SizedBox(
      width: 100.0,
      height: 150.0,
      child: Card(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
                left: 8.0,
                right: 8.0,
              ),
              child: Text(
                "Quote",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Divider(
              thickness: 1.0,
            ),
            Opacity(
              opacity: 0.6,
              child: Text(
                "name",
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            TextButton(
              onPressed: fetchAuthorPropCard,
              child: Text(
                "author",
                style: TextStyle(
                  color: Colors.pink,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Opacity(
              opacity: 0.6,
              child: Text(
                "...",
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget quotidianMiniPlayground() {
    return SizedBox(
      width: 400.0,
      height: 300.0,
      child: Card(
        elevation: 3.0,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              color: stateColors.primary,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      UniconsLine.angle_right,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 16.0,
                        ),
                        text: "curl ",
                        children: [
                          TextSpan(
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w100,
                            ),
                            text: "https://api.fig.style/",
                          ),
                          TextSpan(
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            text: "v1/quotidian",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: 200.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [quotidianCodeBlock()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget quotidianCodeBlock() {
    if (isLoadingQuotidian) {
      return AnimatedAppIcon();
    }

    if (quotidianJson.isEmpty) {
      return OutlinedButton(
        onPressed: fetchQuotidian,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: Text("Run"),
        ),
      );
    }

    return SizedBox(
      height: 236.0,
      width: 390.0,
      child: SyntaxView(
        code: quotidianJson,
        syntaxTheme: stateColors.background == Colors.black
            ? SyntaxTheme.obsidian()
            : SyntaxTheme.gravityLight(),
        syntax: Syntax.JAVASCRIPT,
      ),
    );
  }

  Widget richDataFeature() {
    return Container(
      width: 600.0,
      padding: const EdgeInsets.symmetric(
        vertical: 40.0,
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 40.0,
        children: [
          SizedBox(
            width: 400.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                  opacity: 0.8,
                  child: Text(
                    "More than quotes",
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                  ),
                  child: Opacity(
                    opacity: 0.6,
                    child: Text(
                      "We give maximum context to our data "
                      "so you can often get an author or a reference "
                      "alongside a quote. Authors and references "
                      "have their own data.",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          richDataDiagram(),
        ],
      ),
    );
  }

  Widget richDataDiagram() {
    return SizedBox(
      width: 450.0,
      height: 300.0,
      child: Row(
        children: [
          quotePropCard(),
          Icon(UniconsLine.arrow_right),
          authorPropCard(),
        ],
      ),
    );
  }

  Widget searchFeature() {
    return Container(
      width: 600.0,
      padding: const EdgeInsets.symmetric(
        vertical: 40.0,
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 40.0,
        children: [
          searchMiniPlayground(),
          SizedBox(
            width: 400.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                  opacity: 0.8,
                  child: Text(
                    "Search",
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                  ),
                  child: Opacity(
                    opacity: 0.6,
                    child: Text(
                      "There's a search endpoint "
                      "to find quotes by keywords, topics, or language. "
                      "You can also look for authors or references "
                      "by names.",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget searchMiniPlayground() {
    return SizedBox(
      width: 400.0,
      height: 300.0,
      child: Card(
        elevation: 3.0,
        child: Column(
          children: [
            Container(
              height: 60.0,
              padding: const EdgeInsets.all(16.0),
              color: stateColors.primary,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      UniconsLine.angle_right,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: InkWell(
                      onTap: () => _searchInputFocusNode.requestFocus(),
                      child: Text(
                        "v1/search/quotes?q=",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 100.0,
                    padding: const EdgeInsets.only(right: 24.0),
                    child: TextFormField(
                      autofocus: false,
                      focusNode: _searchInputFocusNode,
                      textInputAction: TextInputAction.go,
                      keyboardType: TextInputType.text,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'révolution',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                        ),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        searchQuery = value;
                      },
                      onFieldSubmitted: (value) => searchQuotes(),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: searchQuotes,
                    child: Text(
                      "Run",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: 200.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [searchCodeBlock()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget searchCodeBlock() {
    if (isLoadingSearch) {
      return AnimatedAppIcon();
    }

    if (searchJson.isEmpty) {
      return OutlinedButton(
        onPressed: searchQuotes,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: Text("Run"),
        ),
      );
    }

    return SizedBox(
      height: 230.0,
      width: 390.0,
      child: SyntaxView(
        code: searchJson,
        syntaxTheme: stateColors.background == Colors.black
            ? SyntaxTheme.obsidian()
            : SyntaxTheme.gravityLight(),
        syntax: Syntax.JAVASCRIPT,
      ),
    );
  }

  Widget techStack() {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Container(
          color: Color.fromRGBO(0, 0, 0, 0.05),
          width: 600.0,
          padding: const EdgeInsets.symmetric(
            vertical: 60.0,
            horizontal: 80.0,
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 40.0,
            children: [
              techStackLeft(),
              teckStackRight(),
            ],
          ),
        ),
      ]),
    );
  }

  Widget techStackLeft() {
    final logoSize = 60.0;

    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              "Tech Stack",
              style: TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => launch("https://cloud.google.com/firestore"),
                child: Image.asset(
                  "assets/images/firestore_logo.png",
                  width: logoSize + 10.0,
                  height: logoSize + 10.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                ),
                child: Icon(UniconsLine.plus),
              ),
              InkWell(
                onTap: () =>
                    launch("https://firebase.google.com/products/functions"),
                child: Image.asset(
                  "assets/images/firebase_cloud_functions_logo.png",
                  width: logoSize,
                  height: logoSize,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                ),
                child: Icon(UniconsLine.plus),
              ),
              InkWell(
                onTap: () => launch("https://algolia.com/"),
                child: Image.asset(
                  "assets/images/algolia_logo.png",
                  width: logoSize,
                  height: logoSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget teckStackRight() {
    return SizedBox(
      width: 400.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: 0.6,
            child: Text(
              "We built our API on robust technologies",
              style: TextStyle(
                fontSize: 24.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Opacity(
              opacity: 0.4,
              child: Text(
                "• Firestore as a NoSQL database, for speed and flexibility.",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Opacity(
              opacity: 0.4,
              child: Text(
                "• Firebase Cloud Functions for the REST API brings optimized usage. ",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Opacity(
              opacity: 0.4,
              child: Text(
                "• Algolia to build a custom search system.",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget verticalCardImage() {
    Widget imgWidget = Container();
    final imageUrl = referenceHeader.urls.image;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      imgWidget = Opacity(
        opacity: 0.3,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: 180.0,
          height: 300.0,
        ),
      );
    }

    return Stack(
      children: [
        imgWidget,
        Positioned.fill(
          child: Opacity(
            opacity: 0.4,
            child: Container(
              color: _imageBackgroundColor,
            ),
          ),
        ),
      ],
    );
  }

  void fetchAuthorPropCard() async {
    setState(() => isLoadingAuthorPropCard = true);

    final today = DateTime.now();
    final createdAt = today.subtract(Duration(days: Random().nextInt(265)));

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('authors')
          .where('createdAt', isGreaterThan: createdAt)
          .limit(1)
          .get();

      if (snapshot.size == 0) {
        snapshot = await FirebaseFirestore.instance
            .collection('authors')
            .where('createdAt', isLessThan: createdAt)
            .limit(1)
            .get();
      }

      if (snapshot.size == 0) {
        return;
      }

      final firstDoc = snapshot.docs.first;
      final data = firstDoc.data();
      data['id'] = firstDoc.id;

      setState(() {
        isLoadingAuthorPropCard = false;
        author = Author.fromJSON(data);
      });
    } catch (error) {
      setState(() => isLoadingAuthorPropCard = false);
      debugPrint(error.toString());
    }
  }

  void fetchQuotidian() async {
    setState(() => isLoadingQuotidian = true);

    try {
      final response = await http.get(quotidianEndpoint);
      final Map<String, dynamic> jsonObj = jsonDecode(response.body);

      setState(() {
        isLoadingQuotidian = false;
        quotidianJson = prettyJson(jsonObj);
      });
    } catch (error) {
      setState(() => isLoadingQuotidian = false);
      debugPrint(error.toString());
    }
  }

  void fetchQuotesHeader() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .where('topics.motivation', isEqualTo: true)
          .where('lang', isEqualTo: 'en')
          .limit(3)
          .get();

      if (snapshot.size < 1) {
        return;
      }

      snapshot.docs.forEach((element) {
        final data = element.data();
        data['id'] = element.id;
        final quote = Quote.fromJSON(data);
        quotesHeader.add(quote);
      });

      setState(() {});
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void fetchHeaderReference() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('references')
          .doc('6j6mk58xtcmANWo7FAQI')
          .get();

      if (!snapshot.exists) {
        return;
      }

      final data = snapshot.data();
      data['id'] = snapshot.id;

      setState(() {
        referenceHeader = Reference.fromJSON(data);
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void searchQuotes() async {
    setState(() {
      isLoadingSearch = true;
      searchQuery = searchQuery.isEmpty ? 'révolution' : searchQuery;
    });

    try {
      final response = await http.get(
        '$searchQuotesEndpoint$searchQuery&limit=3',
        headers: {
          'authorization': ApiKeys.figStyle,
        },
      );

      final Map<String, dynamic> jsonObj = jsonDecode(response.body);

      setState(() {
        isLoadingSearch = false;
        searchJson = prettyJson(jsonObj);
      });
    } catch (error) {
      setState(() => isLoadingSearch = false);
      debugPrint(error.toString());
    }
  }
}
