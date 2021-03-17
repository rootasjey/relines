import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:relines/components/desktop_app_bar.dart';
import 'package:relines/components/fade_in_y.dart';
import 'package:relines/components/footer.dart';
import 'package:relines/components/game_title.dart';
import 'package:relines/components/image_card.dart';
import 'package:relines/components/lang_popup_menu_button.dart';
import 'package:relines/components/rules.dart';
import 'package:relines/components/share_game.dart';
import 'package:relines/router/app_router.gr.dart';
import 'package:relines/state/colors.dart';
import 'package:relines/state/game.dart';
import 'package:relines/types/quote.dart';
import 'package:relines/types/reference.dart';
import 'package:relines/utils/app_storage.dart';
import 'package:relines/utils/constants.dart';
import 'package:relines/utils/fonts.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = false;
  bool isFabVisible = false;

  final _scrollController = ScrollController();

  List<Reference> referencesPresentation = [];
  List<Quote> quotesPresentation = [];

  final quoteEndpoint = "https://api.fig.style/v1/quotes/";
  final referenceEndpoint = "https://api.fig.style/v1/references/";

  List<String> quoteIdsEn = [
    "0EUE8cUP09nQkO4A70oa",
    "0JWVqrrOcx2iKzJrQL6C",
  ];

  List<String> quoteIdsFr = [
    "VkBVvo4a1j0BqFWy6vQs",
    "ap8Lqe76rxPZrzXGOZMk",
  ];

  List<String> referencesIds = [
    "EDRwqgBONNg8cAaAhg8q", // La Révolution
    "F2Li6Usbb6EH4qVFU1zD", // Chilling avdventure of Sabrina
  ];

  @override
  void initState() {
    super.initState();
    fetchPresentationData();
  }

  @override
  dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final left = size.width < Constants.maxMobileWidth ? 0.0 : 65.0;

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
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                DesktopAppBar(
                  padding: EdgeInsets.only(left: left),
                  onTapIconHeader: () {
                    _scrollController.animateTo(
                      0,
                      duration: 250.milliseconds,
                      curve: Curves.decelerate,
                    );
                  },
                ),
                body(),
                footer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget body() {
    final size = MediaQuery.of(context).size;
    final horizontal = size.width < Constants.maxMobileWidth ? 12.0 : 80.0;

    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontal,
            vertical: 80.0,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header(),
                FadeInY(
                  beginY: 20.0,
                  delay: 600.milliseconds,
                  child: Rules(),
                ),
                ShareGame(
                  padding: const EdgeInsets.only(
                    top: 24.0,
                    left: 20.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget footer() {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Footer(),
      ]),
    );
  }

  Widget gameSubtitle() {
    return Opacity(
      opacity: 0.6,
      child: Text(
        "header_subtitle".tr(),
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w200,
        ),
      ),
    );
  }

  Widget header() {
    final size = MediaQuery.of(context).size;
    final horizontal = size.width < Constants.maxMobileWidth ? 0.0 : 40.0;
    final bottom = size.width < Constants.maxMobileWidth ? 40.0 : 0.0;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottom,
      ),
      child: Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - 200.0,
              minWidth: size.width,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontal,
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                runSpacing: 60.0,
                children: [
                  headerLeft(),
                  headerRight(),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              _scrollController.animateTo(
                size.height * 1.0,
                curve: Curves.bounceOut,
                duration: 250.milliseconds,
              );
            },
            icon: Icon(UniconsLine.arrow_down),
          ),
        ],
      ),
    );
  }

  Widget headerLeft() {
    final size = MediaQuery.of(context).size;
    final right = size.width < Constants.maxMobileWidth ? 0.0 : 32.0;
    final left = size.width < Constants.maxMobileWidth ? 12.0 : 0.0;

    return Padding(
      padding: EdgeInsets.only(
        left: left,
        right: right,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeInY(
            beginY: 20.0,
            delay: 100.milliseconds,
            child: GameTitle(),
          ),
          FadeInY(
            beginY: 20.0,
            delay: 300.milliseconds,
            child: gameSubtitle(),
          ),
          FadeInY(
            beginY: 20.0,
            delay: 600.milliseconds,
            child: headerButtons(),
          ),
        ],
      ),
    );
  }

  Widget headerRight() {
    if (referencesPresentation.isEmpty || quotesPresentation.isEmpty) {
      return Container();
    }

    int index = 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 300.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: referencesPresentation.map((reference) {
              index++;

              return FadeInY(
                beginY: 20.0,
                delay: 100.milliseconds * index,
                child: ImageCard(
                  width: 300.0,
                  height: 150.0,
                  name: reference.name,
                  imageUrl: reference.urls.image,
                  padding: EdgeInsets.zero,
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(
          width: 150.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: quotesPresentation.map((quote) {
              return FadeInY(
                  beginY: 20.0,
                  delay: 100.milliseconds * index,
                  child: miniQuoteCard(quote));
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget miniQuoteCard(Quote quote) {
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

  Widget headerButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        maxQuestionsButton(),
        Wrap(
          spacing: 12.0,
          children: [
            langSelector(),
            startGameButton(),
          ],
        ),
      ],
    );
  }

  Widget langSelector() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 9.0,
          horizontal: 12.0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Opacity(
                opacity: 0.8,
                child: Text(
                  "language".tr(),
                  style: FontsUtils.mainStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            LangPopupMenuButton(
              lang: Game.language,
              onLangChanged: (lang) async {
                Locale locale = lang == 'fr' ? Locale('fr') : Locale('en');

                await context.setLocale(locale);
                appStorage.setLang(lang);

                setState(() {
                  Game.setLanguage(lang);
                });

                fetchPresentationData();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget maxQuestionsButton() {
    final questionsText = "questions";

    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        bottom: 16.0,
      ),
      child: Wrap(
        spacing: 16.0,
        children: [
          OutlinedButton(
            onPressed: () {
              setState(() {
                Game.setMaxQuestions(5);
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (Game.maxQuestionsIs(5)) Icon(UniconsLine.check),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text("5 $questionsText"),
                  ),
                ],
              ),
            ),
            style: OutlinedButton.styleFrom(
              primary: Game.maxQuestionsIs(5)
                  ? stateColors.secondary
                  : Theme.of(context).textTheme.bodyText1.color,
            ),
          ),
          OutlinedButton(
            onPressed: () {
              setState(() {
                Game.setMaxQuestions(10);
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (Game.maxQuestionsIs(10)) Icon(UniconsLine.check),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text("10 $questionsText"),
                  ),
                ],
              ),
            ),
            style: OutlinedButton.styleFrom(
              primary: Game.maxQuestionsIs(10)
                  ? stateColors.secondary
                  : stateColors.foreground,
            ),
          ),
          OutlinedButton(
            onPressed: () {
              setState(() {
                Game.setMaxQuestions(20);
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (Game.maxQuestionsIs(20)) Icon(UniconsLine.check),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text("20 $questionsText"),
                  ),
                ],
              ),
            ),
            style: OutlinedButton.styleFrom(
              primary: Game.maxQuestionsIs(20)
                  ? stateColors.secondary
                  : stateColors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget startGameButton() {
    return ElevatedButton(
      onPressed: () {
        context.router.push(PlayRoute());
      },
      style: ElevatedButton.styleFrom(
        primary: stateColors.accent,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 16.0,
        ),
        child: Wrap(
          spacing: 8.0,
          children: [
            Text(
              "start_game".tr(),
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            Icon(UniconsLine.arrow_right),
          ],
        ),
      ),
    );
  }

  void fetchPresentationData() async {
    final quotesFutures = <Future>[];
    final referencesFutures = <Future>[];

    quotesPresentation.clear();
    referencesPresentation.clear();

    List<String> quoteIds = Game.language == 'en' ? quoteIdsEn : quoteIdsFr;

    for (var id in quoteIds) {
      quotesFutures.add(fetchSingleQuote(id));
    }

    for (var id in referencesIds) {
      referencesFutures.add(fetchSingleReference(id));
    }

    await Future.wait([...quotesFutures, ...referencesFutures]);
    setState(() {});
  }

  Future fetchSingleQuote(String quoteId) async {
    try {
      final response = await http.get(
        Uri.parse('$quoteEndpoint$quoteId'),
        headers: {
          'authorization': GlobalConfiguration().getValue<String>("apikey"),
        },
      );

      final Map<String, dynamic> jsonObj = jsonDecode(response.body);
      final quote = Quote.fromJSON(jsonObj['response']);
      quotesPresentation.add(quote);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future fetchSingleReference(String referenceId) async {
    try {
      final response = await http.get(
        Uri.parse('$referenceEndpoint$referenceId'),
        headers: {
          'authorization': GlobalConfiguration().getValue<String>("apikey"),
        },
      );

      final Map<String, dynamic> jsonObj = jsonDecode(response.body);
      final reference = Reference.fromJSON(jsonObj['response']);
      referencesPresentation.add(reference);
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
