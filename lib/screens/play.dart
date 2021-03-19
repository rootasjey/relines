import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:relines/components/animated_app_icon.dart';
import 'package:relines/components/desktop_app_bar.dart';
import 'package:relines/components/footer.dart';
import 'package:relines/components/hud.dart';
import 'package:relines/components/playing.dart';
import 'package:relines/components/results.dart';
import 'package:relines/router/app_router.gr.dart';
import 'package:relines/state/colors.dart';
import 'package:relines/state/game.dart';
import 'package:relines/state/topics_colors.dart';
import 'package:relines/types/author.dart';
import 'package:relines/types/enums.dart';
import 'package:relines/types/game_answer_response.dart';
import 'package:relines/types/game_question_response.dart';
import 'package:relines/types/reference.dart';
import 'package:relines/utils/app_logger.dart';
import 'package:relines/utils/constants.dart';
import 'package:supercharged/supercharged.dart';

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

  int currentQuestionIndex = 0;
  int maxQuestionsCount = 10;
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
                DesktopAppBar(
                  pinned: false,
                  onTapIconHeader: () {
                    _scrollController.animateTo(
                      0,
                      duration: 250.milliseconds,
                      curve: Curves.decelerate,
                    );
                  },
                  onNavBack: () {
                    confirmQuit();
                  },
                ),
                body(),
                Footer(),
              ],
            ),
            Hud(
              score: score,
              currentQuestion: currentQuestionIndex,
              maxQuestions: maxQuestionsCount,
              isVisible: gameState == GameState.running && !isLoading,
              hasChosenAnswer: hasChosenAnswer,
              isCheckingAnswer: isCheckingAnswer,
              onNextQuestion: onNextQuestion,
              onQuit: confirmQuit,
              onSkip: onSkipQuestion,
            ),
          ],
        ),
      ),
    );
  }

  Widget loadingView() {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        SizedBox(
          height: MediaQuery.of(context).size.height - 100.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedAppIcon(),
              Text(
                "loading".tr(),
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

  Widget body() {
    if (isLoading) {
      return loadingView();
    }

    if (gameState == GameState.finished) {
      return Results(
        initGame: initGame,
        onReturnHome: onQuit,
        score: score,
        correctAnswers: correctAnswers,
        maxQuestionsCount: maxQuestionsCount,
      );
    }

    return Playing(
      isCheckingAnswer: isCheckingAnswer,
      isCurrentQuestionCompleted: isCurrentQuestionCompleted,
      accentColor: accentColor,
      answerResponse: answerResponse,
      questionResponse: questionResponse,
      currentQuestionIndex: currentQuestionIndex,
      maxQuestionsCount: maxQuestionsCount,
      quoteName: quoteName,
      questionType: questionType,
      selectedId: selectedId,
      onNextQuestion: onNextQuestion,
      onQuit: confirmQuit,
      onSkipQuestion: onSkipQuestion,
      onPickAnswer: (answerId) {
        if (hasChosenAnswer) {
          return;
        }

        setState(() {
          hasChosenAnswer = true;
          selectedId = answerId;
        });

        checkAnswer(answerId);
      },
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

  void confirmQuit() {
    int flex =
        MediaQuery.of(context).size.width < Constants.maxMobileWidth ? 5 : 3;

    showCustomModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, childSetState) {
            return Material(
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(
                        'confirm'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      trailing: Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                      tileColor: Color(0xfff55c5c),
                      onTap: () {
                        context.router.pop();
                        onQuit();
                      },
                    ),
                    ListTile(
                      title: Text('cancel'.tr()),
                      trailing: Icon(Icons.close),
                      onTap: context.router.pop,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      containerWidget: (context, animation, child) {
        return SafeArea(
          child: Row(
            children: [
              Spacer(),
              Expanded(
                flex: flex,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(12.0),
                    child: child,
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        );
      },
    );
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
        Uri.parse('$questionEndpoint?lang=${Game.language}'),
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
        stateColors.setAccentColor(accentColor);
      });
    } catch (error) {
      setState(() => isLoading = false);
      appLogger.e(responseJsonData.toJSON());
      appLogger.e(error);
      retryFetch();
    }
  }

  void onNextQuestion() {
    setState(() {
      currentQuestionIndex++;
      gameState = currentQuestionIndex > maxQuestionsCount
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
      currentQuestionIndex = 0;
      hasChosenAnswer = false;
      gameState = GameState.stopped;
    });

    context.router.push(HomeRoute());
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
      currentQuestionIndex++;
      hasChosenAnswer = false;
      gameState = currentQuestionIndex > maxQuestionsCount
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
      maxQuestionsCount = Game.maxQuestions;
      currentQuestionIndex = 1;
      hasChosenAnswer = false;
      gameState = GameState.running;
    });

    fetchQuestion();
  }
}
