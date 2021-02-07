import 'dart:convert';

import 'package:disfigstyle/components/animated_app_icon.dart';
import 'package:disfigstyle/components/desktop_app_bar.dart';
import 'package:disfigstyle/components/fade_in_x.dart';
import 'package:disfigstyle/components/fade_in_y.dart';
import 'package:disfigstyle/components/footer.dart';
import 'package:disfigstyle/components/image_card.dart';
import 'package:disfigstyle/state/colors.dart';
import 'package:disfigstyle/state/topics_colors.dart';
import 'package:disfigstyle/types/author.dart';
import 'package:disfigstyle/types/enums.dart';
import 'package:disfigstyle/types/game_answer_response.dart';
import 'package:disfigstyle/types/game_question_response.dart';
import 'package:disfigstyle/types/quote.dart';
import 'package:disfigstyle/types/reference.dart';
import 'package:disfigstyle/utils/api_keys.dart';
import 'package:disfigstyle/utils/constants.dart';
import 'package:disfigstyle/utils/snack.dart';
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
  bool isCompleted = false;
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

    return Container();
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
        children: [
          Text("Checking answer..."),
          AnimatedAppIcon(),
        ],
      );
    }

    return Container();
  }

  Widget finishedView() {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        gameTitle(),
        Text(
          "Thank you for playing with us! ❤️",
          style: TextStyle(
            fontSize: 32.0,
          ),
        ),
        Opacity(
          opacity: 0.7,
          child: Text(
            "With a total of $score, you got $correctAnswers good answers "
            "out of $maxQuestions",
            style: TextStyle(
              fontSize: 24.0,
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

  Widget gameTitle() {
    return Text(
      "Did I Say?",
      style: TextStyle(
        fontSize: 60.0,
        fontFamily: GoogleFonts.pacifico().fontFamily,
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 300.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: referencesPresentation.map((reference) {
              return ImageCard(
                width: 300.0,
                height: 150.0,
                name: reference.name,
                imageUrl: reference.urls.image,
                padding: EdgeInsets.zero,
              );
            }).toList(),
          ),
        ),
        SizedBox(
          width: 150.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: quotesPresentation.map((quote) {
              return miniQuoteCard(quote);
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
                      : stateColors.foreground,
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

  Widget resultBlock() {
    final message = answerResponse.isCorrect
        ? "🎉 Yay! This was the correct answer! 🎉"
        : "🙁 Sorry, this was not the correct answer. "
            "It was ${answerResponse.correction.name}";

    return Container(
      width: 600.0,
      padding: const EdgeInsets.only(bottom: 40.0),
      child: Column(
        children: [
          Text(
            message,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          Wrap(
            spacing: 20.0,
            children: [
              ElevatedButton(
                onPressed: quitGame,
                child: Text("Quit"),
              ),
              ElevatedButton(
                onPressed: nextQuestion,
                child: Text("Next question"),
              ),
            ],
          ),
        ],
      ),
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
            child: Column(
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
                basicRules(),
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
    setState(() {
      isCheckingAnswer = true;
    });

    try {
      final response = await http.post(
        '$answerEndpoint',
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

      print('checinkg answer done');

      if (answerResponse.isCorrect) {
        correctAnswers++;
        return;
      }
    } catch (error) {
      setState(() => isLoading = false);
      debugPrint(error.toString());
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
        '$questionEndpoint',
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
    });

    fetchQuestion();
  }

  void quitGame() {
    setState(() {
      gameState = GameState.stopped;
      currentQuestion = 0;
    });
  }

  void skipQuestion() async {
    setState(() {
      currentQuestion++;
      isCompleted = currentQuestion >= maxQuestions;
      isLoading = !isCompleted;
    });

    fetchQuestion();
  }

  void startGame() {
    setState(() {
      currentQuestion = 0;
      score = 0;
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
        '$quoteEndpoint$quoteId',
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
        '$referenceEndpoint$referenceId',
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
