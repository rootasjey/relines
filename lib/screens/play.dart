import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:relines/components/animated_app_icon.dart';
import 'package:relines/components/desktop_app_bar.dart';
import 'package:relines/components/fade_in_x.dart';
import 'package:relines/components/fade_in_y.dart';
import 'package:relines/components/footer.dart';
import 'package:relines/components/hud.dart';
import 'package:relines/components/image_card.dart';
import 'package:relines/components/rules.dart';
import 'package:relines/router/app_router.gr.dart';
import 'package:relines/state/colors.dart';
import 'package:relines/state/topics_colors.dart';
import 'package:relines/types/author.dart';
import 'package:relines/types/enums.dart';
import 'package:relines/types/game_answer_response.dart';
import 'package:relines/types/game_question_response.dart';
import 'package:relines/types/reference.dart';
import 'package:relines/utils/app_logger.dart';
import 'package:relines/utils/constants.dart';
import 'package:relines/utils/fonts.dart';
import 'package:relines/utils/snack.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class Play extends StatefulWidget {
  @override
  _PlayState createState() => _PlayState();
}

class _PlayState extends State<Play> {
  bool hasChosenAnswer = false;
  bool isCheckingAnswer = false;
  bool isCurrentQuestionCompleted = false;
  bool isLoading = false;
  bool isFabVisible = false;

  final _scrollController = ScrollController();

  Color accentColor = Colors.blue;

  final questionEndpoint = "https://api.fig.style/v1/dis/random";
  final answerEndpoint = "https://api.fig.style/v1/dis/check";

  int currentQuestion = 0;
  int maxQuestions = 10;
  int correctAnswers = 0;
  int score = 0;

  int currentFetchRetry = 0;
  int maxFetchRetry = 3;

  List<Author> authors = [];
  List<Reference> references = [];
  List<Reference> referencesPresentation = [];
  List<String> previousQuestionsIds = [];

  GameAnswerResponse answerResponse;
  GameQuestionResponse questionResponse;

  GameState gameState = GameState.stopped;

  Map<String, dynamic> responseJsonData;

  String quoteName = '';
  String questionType = 'author';
  String selectedId = '';

  @override
  initState() {
    super.initState();
    initGame();
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
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                DesktopAppBar(
                  padding: const EdgeInsets.only(left: 65.0),
                  onTapIconHeader: () {
                    if (_scrollController.offset < 10.0) {
                      context.router.navigate(HomeRoute());
                      return;
                    }

                    _scrollController.animateTo(
                      0,
                      duration: 250.milliseconds,
                      curve: Curves.decelerate,
                    );
                  },
                ),
                playView(),
                footer(),
              ],
            ),
            Positioned(
              top: 160.0,
              right: 24.0,
              child: Hud(
                score: score,
                currentQuestion: currentQuestion,
                maxQuestions: maxQuestions,
                onQuit: onQuit,
                onSkip: onSkipQuestion,
                isVisible: gameState == GameState.running || !isLoading,
              ),
            ),
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
                    onPressed: onQuit,
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

    if (questionResponse.authorProposals == null) {
      return Container();
    }

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
              type: ImageCardType.extended,
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
                      onPressed: initGame,
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

  Widget gameTitle() {
    return Text(
      "Relines",
      style: FontsUtils.mainStyle(
        fontSize: 60.0,
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

  Widget playView() {
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
                FadeInY(
                  beginY: 20.0,
                  delay: 1200.milliseconds,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 200.0),
                    child: Rules(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
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

    if (questionResponse.referenceProposals == null) {
      return Container();
    }

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
              type: ImageCardType.extended,
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

              Snack.i(
                context: context,
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
        onPressed: onSkipQuestion,
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
      previousQuestionsIds.add(proposalId);
    });

    try {
      final response = await http.post(
        Uri.parse(answerEndpoint),
        headers: {
          'authorization': GlobalConfiguration().getValue<String>("apikey"),
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
      selectedId = '';
    });

    try {
      final response = await http.post(
        Uri.parse(questionEndpoint),
        headers: {
          'authorization': GlobalConfiguration().getValue<String>("apikey"),
        },
        body: {
          'previousQuestionsIds': jsonEncode(previousQuestionsIds),
        },
      );

      responseJsonData = jsonDecode(response.body);
      questionResponse =
          GameQuestionResponse.fromJSON(responseJsonData['response']);

      final topicName =
          questionResponse.question.quote.topics.firstOrElse(() => "fun");

      setState(() {
        isLoading = false;
        currentFetchRetry = 0;

        questionType = questionResponse.question.guessType;
        quoteName = questionResponse.question.quote.name;
        accentColor = appTopicsColors.getColorFor(topicName);
      });
    } catch (error) {
      setState(() => isLoading = false);
      appLogger.e(responseJsonData.toJSON());
      appLogger.e(error);
      retryFetch();
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

  void onQuit() {
    setState(() {
      score = 0;
      currentQuestion = 0;
      hasChosenAnswer = false;
      gameState = GameState.stopped;
    });

    context.router.navigate(HomeRoute());
  }

  void retryFetch() {
    appLogger.d("Retry $currentFetchRetry / $maxFetchRetry");

    if (currentFetchRetry > maxFetchRetry) {
      return;
    }

    currentFetchRetry++;
    fetchQuestion();
  }

  void onSkipQuestion() async {
    if (isLoading) {
      return;
    }

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

  void initGame() {
    setState(() {
      score = 0;
      currentQuestion = 1;
      hasChosenAnswer = false;
      gameState = GameState.running;
    });

    fetchQuestion();
  }
}
