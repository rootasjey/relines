import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
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
import 'package:relines/utils/language.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

List<Reference> _referencesPresentation = [];
List<Quote> _quotesPresentation = [];

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = false;
  bool isFabVisible = false;

  final _scrollController = ScrollController();

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

    Game.setMaxQuestions(appStorage.getMaxQuestions());

    if (_referencesPresentation.isEmpty || _quotesPresentation.isEmpty) {
      fetchPresentationData();
    }
  }

  @override
  dispose() {
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
          // if (scrollNotif.metrics.pixels < 50 && isFabVisible) {
          //   setState(() => isFabVisible = false);
          // } else if (scrollNotif.metrics.pixels > 50 && !isFabVisible) {
          //   setState(() => isFabVisible = true);
          // }

          return false;
        },
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                appBar(),
                body(),
                Footer(),
              ],
            ),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: stateColors.tileBackground,
                    border: Border(
                      top: BorderSide(
                        color: stateColors.foreground.withOpacity(0.1),
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceAround,
                    children: [
                      langSelector(),
                      startGameButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget appBar() {
    if (kIsWeb) {
      return DesktopAppBar(
        onTapIconHeader: () {
          _scrollController.animateTo(
            0,
            duration: 250.milliseconds,
            curve: Curves.decelerate,
          );
        },
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(top: 80.0),
    );
  }

  Widget body() {
    final size = MediaQuery.of(context).size;
    final paddingValue = size.width < Constants.maxMobileWidth ? 0.0 : 80.0;

    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Padding(
          padding: EdgeInsets.all(paddingValue),
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
          // FadeInY(
          //   beginY: 20.0,
          //   delay: 600.milliseconds,
          //   child: headerButtons(),
          // ),
        ],
      ),
    );
  }

  Widget headerRight() {
    if (_referencesPresentation.isEmpty || _quotesPresentation.isEmpty) {
      return Container();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 320.0,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              SizedBox(
                width: 300.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      _referencesPresentation.mapIndexed((index, reference) {
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
                  children: _quotesPresentation.mapIndexed((index, quote) {
                    return FadeInY(
                        beginY: 20.0,
                        delay: 100.milliseconds * index,
                        child: miniQuoteCard(quote));
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        maxQuestionsButton(),
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
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
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
      ),
    );
  }

  Widget langSelector() {
    return LangPopupMenuButton(
      elevation: 2.0,
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 16.0,
      ),
      lang: Language.frontend(Game.language),
      onLangChanged: (lang) async {
        Locale locale = lang == 'fr' ? Locale('fr') : Locale('en');

        await context.setLocale(locale);
        appStorage.setLang(lang);

        setState(() {
          Game.setLanguage(lang);
        });

        fetchPresentationData();
      },
    );
  }

  Widget maxQuestionsButton() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 12.0,
        bottom: 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: 0.6,
            child: Text(
              "Questions",
              style: FontsUtils.mainStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Wrap(
            spacing: 16.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  const max = 5;
                  appStorage.setMaxQuestions(max);

                  setState(() {
                    Game.setMaxQuestions(max);
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
                        child: Text("5"),
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
                  const max = 10;
                  appStorage.setMaxQuestions(max);

                  setState(() {
                    Game.setMaxQuestions(max);
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
                        child: Text("10"),
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
                  const max = 20;
                  appStorage.setMaxQuestions(max);

                  setState(() {
                    Game.setMaxQuestions(max);
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
                        child: Text("20"),
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

    _quotesPresentation.clear();
    _referencesPresentation.clear();

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
      _quotesPresentation.add(quote);
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
      _referencesPresentation.add(reference);
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
