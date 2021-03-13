import 'dart:convert';

import 'package:relines/components/animated_app_icon.dart';
import 'package:relines/components/desktop_app_bar.dart';
import 'package:relines/components/fade_in_x.dart';
import 'package:relines/components/fade_in_y.dart';
import 'package:relines/components/footer.dart';
import 'package:relines/components/image_card.dart';
import 'package:relines/state/colors.dart';
import 'package:relines/state/topics_colors.dart';
import 'package:relines/types/author.dart';
import 'package:relines/types/enums.dart';
import 'package:relines/types/game_answer_response.dart';
import 'package:relines/types/game_question_response.dart';
import 'package:relines/types/quote.dart';
import 'package:relines/types/reference.dart';
import 'package:relines/utils/api_keys.dart';
import 'package:relines/utils/constants.dart';
import 'package:relines/utils/snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supercharged/supercharged.dart';
import 'package:http/http.dart' as http;
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = false;
  bool isFabVisible = false;
  bool hasChosenAnswer = false;
  bool isCheckingAnswer = false;
  bool isCurrentQuestionCompleted = false;

  Color accentColor = Colors.blue;

  final _scrollController = ScrollController();

  int currentQuestion = 0;
  int maxQuestions = 10;
  int correctAnswers = 0;
  int score = 0;

  final questionEndpoint = "https://api.fig.style/v1/dis/random";
  final answerEndpoint = "https://api.fig.style/v1/dis/check";
  final quoteEndpoint = "https://api.fig.style/v1/quotes/";
  final referenceEndpoint = "https://api.fig.style/v1/references/";

  GameAnswerResponse answerResponse;
  GameQuestionResponse questionResponse;

  GameState gameState = GameState.stopped;

  List<Author> authors = [];
  List<Reference> references = [];
  List<Reference> referencesPresentation = [];
  List<Quote> quotesPresentation = [];

  List<String> quotesIds = [
    "0EUE8cUP09nQkO4A70oa",
    "0JWVqrrOcx2iKzJrQL6C",
  ];

  List<String> referencesIds = [
    "EDRwqgBONNg8cAaAhg8q", // La Révolution
    "F2Li6Usbb6EH4qVFU1zD", // Chilling avdventure of Sabrina
  ];

  String quoteName = '';
  String questionType = 'author';
  String selectedId = '';

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
            body(),
            footer(),
          ],
        ),
      ),
    );
  }

  Widget answerResultBlock() {
    if (!isCurrentQuestionCompleted) {
      return Container();
    }

    Widget textMessageWidget = Text("");

    if (answerResponse.isCorrect) {
      textMessageWidget = Text(
        "🎉 Yay! This was the correct answer! 🎉",
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
        ),
      );
    } else {
      textMessageWidget = RichText(
        text: TextSpan(
          text: "🙁  Sorry, this was not the correct answer. It was ",
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
            color: stateColors.foreground,
          ),
          children: [
            TextSpan(
              text: answerResponse.correction.name,
              style: TextStyle(
                color: Colors.green,
                fontSize: 16.0,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: 600.0,
      padding: const EdgeInsets.only(bottom: 40.0),
      child: Card(
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: textMessageWidget,
              ),
              Wrap(
                spacing: 20.0,
                children: [
                  OutlinedButton(
                    onPressed: quitGame,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Text("Quit"),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: nextQuestion,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentQuestion > maxQuestions
                                ? "See results"
                                : "Next question",
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(UniconsLine.arrow_right),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget authorsRow() {
    int index = 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: questionResponse.authorProposals.values.map(
        (proposal) {
          index++;
          return FadeInX(
            beginX: 20.0,
            delay: Duration(milliseconds: 200 * index),
            child: ImageCard(
              name: proposal.name,
              imageUrl: proposal.urls.image,
              selected: selectedId == proposal.id,
              onTap: () {
                if (hasChosenAnswer) {
                  return;
                }

                setState(() {
                  hasChosenAnswer = true;
                  selectedId = proposal.id;
                });

                checkAnswer(proposal.id);
              },
            ),
          );
        },
      ).toList(),
    );
  }

  Widget body() {
    if (gameState == GameState.stopped) {
      return notStartedView();
    }

    if (gameState == GameState.finished) {
      return finishedView();
    }

    return runningGameView();
  }

  Widget checkingAnswerBlock() {
    if (isCheckingAnswer) {
      return Wrap(
        spacing: 16.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            "Checking answer...",
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
          AnimatedAppIcon(size: 70.0),
        ],
      );
    }

    return Container();
  }

  Widget finishedView() {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Container(
          width: 700.0,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(80.0),
          child: Column(
            children: [
              gameTitle(),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Opacity(
                    opacity: 0.6,
                    child: Text(
                      "Thank you for playing with us!",
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w100,
                        decoration: TextDecoration.underline,
                        decorationColor:
                            stateColors.foreground.withOpacity(0.4),
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
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Wrap(
                  spacing: 12.0,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() => gameState = GameState.stopped);
                      },
                      icon: Icon(UniconsLine.home),
                      label: Text("Return home"),
                      style: TextButton.styleFrom(
                        primary: stateColors.foreground.withOpacity(0.5),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: startGame,
                      icon: Icon(UniconsLine.refresh),
                      label: Text("Play again"),
                      style: TextButton.styleFrom(
                        primary: stateColors.foreground.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
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
                        Padding(
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
                                "Result",
                                style: TextStyle(
                                  color: Colors.yellow.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            text: "You made a total of ",
                            children: [
                              TextSpan(
                                text: "$score points, ",
                                style: TextStyle(
                                  fontSize: 24.0,
                                  color: Colors.yellow.shade800,
                                ),
                              ),
                              TextSpan(
                                text: "you got ",
                              ),
                              TextSpan(
                                text: "$correctAnswers good answers ",
                                style: TextStyle(
                                  fontSize: 24.0,
                                  color: Colors.yellow.shade800,
                                ),
                              ),
                              TextSpan(
                                text: "out of ",
                              ),
                              TextSpan(
                                text: "$maxQuestions in total.",
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              shareScoreButtons(),
            ],
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

  Widget gameTitle() {
    return Text(
      "Did I Say?",
      style: TextStyle(
        fontSize: 60.0,
        fontFamily: GoogleFonts.pacifico().fontFamily,
      ),
    );
  }

  Widget hud() {
    return Container(
      width: 180.0,
      child: Card(
        elevation: 0.0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
          side: BorderSide(
            color: stateColors.primary,
            width: 2.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  children: [
                    Icon(
                      UniconsLine.award,
                      color: Colors.yellow.shade800,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text("$score points"),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  children: [
                    Icon(
                      UniconsLine.question,
                      color: Colors.green,
                    ),
                    Text("question $currentQuestion / $maxQuestions"),
                  ],
                ),
              ),
              Wrap(
                alignment: WrapAlignment.start,
                children: [
                  TextButton(
                    onPressed: quitGame,
                    child: Wrap(
                      children: [
                        Text("Quit"),
                      ],
                    ),
                    style: TextButton.styleFrom(
                      primary: Colors.pink,
                    ),
                  ),
                  TextButton(
                    onPressed: skipQuestion,
                    child: Wrap(
                      children: [
                        Text("Skip"),
                      ],
                    ),
                    style: TextButton.styleFrom(
                      primary: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget notStartedView() {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Padding(
          padding: const EdgeInsets.all(80.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                notStartedHeader(),
                FadeInY(
                  beginY: 20.0,
                  delay: 600.milliseconds,
                  child: basicRules(),
                ),
                shareGameButtons(),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget notStartedHeader() {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 200.0,
          padding: const EdgeInsets.symmetric(
            horizontal: 40.0,
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              headerLeft(),
              headerRight(),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            _scrollController.animateTo(
              MediaQuery.of(context).size.height * 1.0,
              curve: Curves.bounceOut,
              duration: 250.milliseconds,
            );
          },
          icon: Icon(UniconsLine.arrow_down),
        ),
      ],
    );
  }

  Widget headerLeft() {
    return Padding(
      padding: const EdgeInsets.only(right: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeInY(
            beginY: 20.0,
            delay: 100.milliseconds,
            child: gameTitle(),
          ),
          FadeInY(
            beginY: 20.0,
            delay: 300.milliseconds,
            child: Opacity(
              opacity: 0.6,
              child: Text(
                "This is a quotes game",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
          ),
          FadeInY(
            beginY: 20.0,
            delay: 600.milliseconds,
            child: notStartedButtons(),
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

  Widget basicRules() {
    final titleFontSize = 60.0;
    final textFontSize = 16.0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Rules",
            style: TextStyle(
              color: stateColors.secondary,
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
              bottom: 24.0,
            ),
            child: Opacity(
              opacity: 0.6,
              child: RichText(
                text: TextSpan(
                  text:
                      "Each round, you have to guess the author or the reference "
                      "of the displayed quote. The question type alternate randomly."
                      "For example, on the 1st round, you must guess the author, "
                      "and on the next 2nd round, you must guess the reference.",
                  style: TextStyle(
                    color: stateColors.foreground,
                    fontSize: textFontSize,
                    fontWeight: FontWeight.w100,
                  ),
                  children: [],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 24.0,
            ),
            child: Opacity(
              opacity: 0.6,
              child: RichText(
                text: TextSpan(
                  text: "For each good answer, you earn 10 points. "
                      "Wrong answers make you loose 5 points."
                      "1 point is used if you skip one question.",
                  style: TextStyle(
                    color: stateColors.foreground,
                    fontSize: textFontSize,
                    fontWeight: FontWeight.w100,
                  ),
                  children: [],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 24.0,
            ),
            child: Opacity(
              opacity: 0.6,
              child: RichText(
                text: TextSpan(
                  text: "You can choose a game in 5 questions, "
                      "10 questions or 20 questions.",
                  style: TextStyle(
                    color: stateColors.foreground,
                    fontSize: textFontSize,
                    fontWeight: FontWeight.w100,
                  ),
                  children: [],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 24.0,
            ),
            child: Opacity(
              opacity: 0.6,
              child: RichText(
                text: TextSpan(
                  text: "Save your progress and your games "
                      "by connecting to your account. Or create one "
                      "if you didn't already.",
                  style: TextStyle(
                    color: stateColors.foreground,
                    fontSize: textFontSize,
                    fontWeight: FontWeight.w100,
                  ),
                  children: [],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget notStartedButtons() {
    final questionsText = "questions";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
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
                    maxQuestions = 5;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (maxQuestions == 5) Icon(UniconsLine.check),
                      Text("5 $questionsText"),
                    ],
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  primary: maxQuestions == 5
                      ? stateColors.secondary
                      : Theme.of(context).textTheme.bodyText1.color,
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    maxQuestions = 10;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (maxQuestions == 10) Icon(UniconsLine.check),
                      Text("10 $questionsText"),
                    ],
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  primary: maxQuestions == 10
                      ? stateColors.secondary
                      : stateColors.foreground,
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    maxQuestions = 20;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (maxQuestions == 5) Icon(UniconsLine.check),
                      Text("20 $questionsText"),
                    ],
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  primary: maxQuestions == 20
                      ? stateColors.secondary
                      : stateColors.foreground,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: startGame,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Wrap(
              spacing: 8.0,
              children: [
                Text(
                  "Start game",
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                Icon(UniconsLine.arrow_right),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget proposalsBlock() {
    if (questionType == 'author') {
      return authorsRow();
    }

    return referencesRow();
  }

  Widget quoteBlock() {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 700.0),
      child: Opacity(
        opacity: 0.8,
        child: Text(
          quoteName,
          style: TextStyle(
            fontSize: 42.0,
            fontWeight: FontWeight.w300,
            decoration: TextDecoration.underline,
            decorationColor: accentColor.withOpacity(0.2),
          ),
        ),
      ),
    );
  }

  Widget referencesRow() {
    int index = 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: questionResponse.referenceProposals.values.map(
        (proposal) {
          index++;

          return FadeInX(
            beginX: 20.0,
            delay: Duration(milliseconds: 200 * index),
            child: ImageCard(
              name: proposal.name,
              imageUrl: proposal.urls.image,
              selected: selectedId == proposal.id,
              onTap: () {
                if (hasChosenAnswer) {
                  return;
                }

                setState(() {
                  hasChosenAnswer = true;
                  selectedId = proposal.id;
                });

                checkAnswer(proposal.id);
              },
            ),
          );
        },
      ).toList(),
    );
  }

  Widget runningGameView() {
    if (isLoading) {
      return runningLoadingView();
    }

    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Padding(
          padding: const EdgeInsets.all(80.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    checkingAnswerBlock(),
                    answerResultBlock(),
                    FadeInY(
                      beginY: 20.0,
                      delay: 100.milliseconds,
                      child: quoteBlock(),
                    ),
                    FadeInY(
                      beginY: 20.0,
                      delay: 300.milliseconds,
                      child: subtitleBlock(),
                    ),
                    FadeInY(
                      beginY: 20.0,
                      delay: 600.milliseconds,
                      child: proposalsBlock(),
                    ),
                    FadeInY(
                      beginY: 20.0,
                      delay: 900.milliseconds,
                      child: skipButton(),
                    ),
                    FadeInY(
                      beginY: 20.0,
                      delay: 1200.milliseconds,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 200.0),
                        child: basicRules(),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 0.0,
                  right: 0.0,
                  child: hud(),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget runningLoadingView() {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        SizedBox(
          height: MediaQuery.of(context).size.height - 100.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedAppIcon(),
              Text(
                "Loading...",
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget shareGameButtons() {
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

            showSnack(
              context: context,
              type: SnackType.info,
              message: "Link successfully copied!",
            );
          },
          icon: Icon(UniconsLine.link),
        ),
      ],
    );
  }

  Widget shareScoreButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 60.0),
      child: Wrap(
        spacing: 24.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          TextButton.icon(
            onPressed: () {
              launch(
                "${Constants.baseTwitterShareUrl}I made a score of "
                "$score points, answering right "
                "to $correctAnswers out of $maxQuestions."
                "${Constants.twitterShareHashtags}"
                "&url=https://dis.fig.style",
              );
            },
            icon: Icon(UniconsLine.twitter),
            label: Text("Share on Twitter"),
          ),
          IconButton(
            tooltip: "Copy result message",
            onPressed: () {
              Clipboard.setData(
                ClipboardData(
                  text: "I made a score of "
                      "$score points, answering right "
                      "to $correctAnswers out of $maxQuestions. "
                      "Can you do more? (${Constants.disUrl})",
                ),
              );

              showSnack(
                context: context,
                type: SnackType.info,
                message: "Link successfully copied!",
              );
            },
            icon: Icon(UniconsLine.link),
          ),
        ],
      ),
    );
  }

  Widget skipButton() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
      ),
      child: TextButton(
        onPressed: skipQuestion,
        child: Text(
          "Skip that one...",
        ),
      ),
    );
  }

  Widget subtitleBlock() {
    String helpText = questionType == 'author'
        ? "Who, among these 3 authors, said that quote?"
        : "What's that quote reference?";

    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        bottom: 32.0,
      ),
      child: Opacity(
        opacity: 0.5,
        child: Text(
          helpText,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void checkAnswer(String proposalId) async {
    _scrollController.animateTo(
      0,
      curve: Curves.bounceOut,
      duration: 250.milliseconds,
    );

    setState(() {
      isCheckingAnswer = true;
    });

    try {
      final response = await http.post(
        Uri.parse(answerEndpoint),
        headers: {
          'authorization': ApiKeys.figStyle,
        },
        body: {
          'answerProposalId': proposalId,
          'guessType': questionType,
          'quoteId': questionResponse.question.quote.id,
        },
      );

      final Map<String, dynamic> jsonObj = jsonDecode(response.body);

      setState(() {
        answerResponse = GameAnswerResponse.fromJSON(jsonObj['response']);
        isCheckingAnswer = false;
        isCurrentQuestionCompleted = true;
      });

      if (answerResponse.isCorrect) {
        setState(() {
          correctAnswers++;
          score += 10;
        });
        return;
      }

      setState(() {
        score -= 5;
      });
    } catch (error) {
      setState(() => isLoading = false);
      debugPrint(error.toString());
      debugPrint(
        "This was the quote to answer: "
        "${questionResponse.question.quote.id}",
      );
      debugPrint(
        "This was the proposed answer: "
        "$proposalId",
      );
      debugPrint(
        "This was the guess type: "
        "$questionType",
      );
    }
  }

  void fetchQuestion() async {
    setState(() {
      isLoading = true;
      isCheckingAnswer = false;
      isCurrentQuestionCompleted = false;
    });

    try {
      final response = await http.get(
        Uri.parse(questionEndpoint),
        headers: {
          'authorization': ApiKeys.figStyle,
        },
      );

      final Map<String, dynamic> jsonObj = jsonDecode(response.body);
      questionResponse = GameQuestionResponse.fromJSON(jsonObj['response']);

      final topicName =
          questionResponse.question.quote.topics.firstOrElse(() => "fun");

      setState(() {
        isLoading = false;

        questionType = questionResponse.question.guessType;
        quoteName = questionResponse.question.quote.name;
        accentColor = appTopicsColors.getColorFor(topicName);
      });
    } catch (error) {
      setState(() => isLoading = false);
      debugPrint(error.toString());
    }
  }

  void nextQuestion() {
    setState(() {
      currentQuestion++;
      gameState = currentQuestion > maxQuestions
          ? GameState.finished
          : GameState.running;
      hasChosenAnswer = false;
    });

    if (gameState == GameState.finished) {
      return;
    }

    fetchQuestion();
  }

  void quitGame() {
    setState(() {
      score = 0;
      currentQuestion = 0;
      hasChosenAnswer = false;
      gameState = GameState.stopped;
    });
  }

  void skipQuestion() async {
    setState(() {
      currentQuestion++;
      hasChosenAnswer = false;
      gameState = currentQuestion > maxQuestions
          ? GameState.finished
          : GameState.running;
      isLoading = false;
      score -= 1;
    });

    if (gameState == GameState.finished) {
      return;
    }

    fetchQuestion();
  }

  void startGame() {
    setState(() {
      score = 0;
      currentQuestion = 1;
      hasChosenAnswer = false;
      gameState = GameState.running;
    });

    fetchQuestion();
  }

  void fetchPresentationData() async {
    final quotesFutures = <Future>[];
    final referencesFutures = <Future>[];

    for (var id in quotesIds) {
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
          'authorization': ApiKeys.figStyle,
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
          'authorization': ApiKeys.figStyle,
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
