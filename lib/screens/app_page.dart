import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:disfigstyle/components/empty_content.dart';
import 'package:disfigstyle/components/fade_in_y.dart';
import 'package:disfigstyle/components/loading_animation.dart';
import 'package:disfigstyle/components/page_app_bar.dart';
import 'package:disfigstyle/components/sliver_edge_padding.dart';
import 'package:disfigstyle/router/app_router.gr.dart';
import 'package:disfigstyle/state/colors.dart';
import 'package:disfigstyle/types/request_app_response.dart';
import 'package:disfigstyle/types/enums.dart';
import 'package:disfigstyle/types/user_app.dart';
import 'package:disfigstyle/utils/constants.dart';
import 'package:disfigstyle/utils/snack.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class AppPage extends StatefulWidget {
  final String appId;

  const AppPage({Key key, @PathParam() this.appId}) : super(key: key);

  @override
  _AppPageState createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  bool isFabVisible = false;
  bool isLoading = false;
  bool showPrimaryKey = false;
  bool showSecondaryKey = false;
  bool isEditingAppName = false;

  double cardHeight = 160.0;

  final cardWidth = 800.0;
  final ScrollController scrollController = ScrollController();

  FocusNode appDescriptionFocusNode;

  TextEditingController appNameController;
  TextEditingController appDescriptionController;

  String appName = '';
  String appDesc = '';

  UserApp userApp;

  @override
  initState() {
    super.initState();
    appDescriptionFocusNode = FocusNode();
    appNameController = TextEditingController();
    appDescriptionController = TextEditingController();

    fetch();
  }

  @override
  dispose() {
    appDescriptionFocusNode?.dispose();
    appNameController?.dispose();
    appDescriptionController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isFabVisible
          ? FloatingActionButton(
              onPressed: () {
                scrollController.animateTo(
                  0.0,
                  duration: 250.milliseconds,
                  curve: Curves.easeOut,
                );
              },
              backgroundColor: stateColors.primary,
              foregroundColor: Colors.white,
              child: Icon(Icons.arrow_upward),
            )
          : null,
      body: OrientationBuilder(
        builder: (context, orientation) {
          final screenWidth = MediaQuery.of(context).size.width;

          return NotificationListener(
            onNotification: (ScrollNotification scrollNotif) {
              // FAB visibility
              if (scrollNotif.metrics.pixels < 50 && isFabVisible) {
                setState(() {
                  isFabVisible = false;
                });
              } else if (scrollNotif.metrics.pixels > 50 && !isFabVisible) {
                setState(() {
                  isFabVisible = true;
                });
              }

              return false;
            },
            child: Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (_) => CustomScrollView(
                    controller: scrollController,
                    slivers: <Widget>[
                      SliverEdgePadding(),
                      appBar(),
                      body(screenWidth: screenWidth),
                      SliverPadding(
                        padding: const EdgeInsets.only(bottom: 200.0),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget appBar() {
    final width = MediaQuery.of(context).size.width;
    double titleLeftPadding = 70.0;
    double bottomContentLeftPadding = 94.0;

    if (width < Constants.maxMobileWidth) {
      titleLeftPadding = 0.0;
      bottomContentLeftPadding = 24.0;
    }

    return PageAppBar(
      textTitle: 'Apps',
      textSubTitle: 'Your developer apps',
      titlePadding: EdgeInsets.only(
        left: titleLeftPadding,
      ),
      bottomPadding: EdgeInsets.only(
        left: bottomContentLeftPadding,
        bottom: 10.0,
      ),
      showNavBackIcon: true,
      onTitlePressed: () {
        scrollController.animateTo(
          0,
          duration: 250.milliseconds,
          curve: Curves.easeIn,
        );
      },
    );
  }

  Widget apiKeysCard() {
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              "Primary API key",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Opacity(
                            opacity: 0.6,
                            child: Text(
                              "This is your public API key to use in your frontend code. "
                              "It is the primary one.",
                              style: TextStyle(
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    showPrimaryKey
                        ? userApp.keys.primary
                        : userApp.keys.primary.replaceAll(RegExp("."), "*"),
                  ),
                  IconButton(
                    onPressed: () =>
                        setState(() => showPrimaryKey = !showPrimaryKey),
                    icon: showPrimaryKey
                        ? Icon(UniconsLine.eye_slash)
                        : Icon(UniconsLine.eye),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: userApp.keys.primary),
                      );

                      showSnack(
                        context: context,
                        type: SnackType.info,
                        message: "Primary key successfully copied!",
                      );
                    },
                    icon: Icon(UniconsLine.copy),
                  ),
                ],
              ),
              Padding(padding: const EdgeInsets.only(top: 32.0)),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              "Secondary API key",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Opacity(
                            opacity: 0.6,
                            child: Text(
                              "This is your secondary API key to use in backup "
                              "if your primary key is compromised.",
                              style: TextStyle(
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    showSecondaryKey
                        ? userApp.keys.secondary
                        : userApp.keys.secondary.replaceAll(RegExp("."), "*"),
                  ),
                  IconButton(
                    onPressed: () =>
                        setState(() => showSecondaryKey = !showSecondaryKey),
                    icon: showSecondaryKey
                        ? Icon(UniconsLine.eye_slash)
                        : Icon(UniconsLine.eye),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: userApp.keys.secondary),
                      );

                      showSnack(
                        context: context,
                        type: SnackType.info,
                        message: "Secondary key successfully copied!",
                      );
                    },
                    icon: Icon(UniconsLine.copy),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget appIdCard() {
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "Application ID",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: 0.6,
                        child: Text(
                          "This is your unique application identifier. "
                          "It's used to identify you when using fig.style's API.",
                          style: TextStyle(
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                userApp.id,
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: userApp.id));

                  showSnack(
                    context: context,
                    type: SnackType.info,
                    message: "Application's id successfully copied!",
                  );
                },
                icon: Icon(UniconsLine.copy),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget appNameCard() {
    return Container(
      width: cardWidth,
      height: cardHeight,
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
      ),
      child: Card(
        color: stateColors.primary,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: isEditingAppName ? appNameEditCard() : appNameIdleCard(),
        ),
      ),
    );
  }

  Widget appNameIdleCard() {
    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              Text(
                userApp.name,
                style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Opacity(
                opacity: 0.6,
                child: Text(
                  userApp.description,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0.0,
          right: 0.0,
          bottom: 0.0,
          child: Opacity(
            opacity: 0.6,
            child: IconButton(
              tooltip: "Edit app's name & description",
              onPressed: () {
                setState(() {
                  cardHeight = 240.0;
                  appName = userApp.name ?? '';
                  appDesc = userApp.description ?? '';
                  isEditingAppName = true;
                });
              },
              icon: Icon(
                UniconsLine.edit,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget appNameInput() {
    return SizedBox(
      width: 300.0,
      child: TextFormField(
        autofocus: true,
        initialValue: appName,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          icon: Icon(Icons.location_history_sharp),
          labelText: "App's name",
        ),
        onChanged: (value) {
          appName = value;
        },
        onFieldSubmitted: (value) => appDescriptionFocusNode.requestFocus(),
        validator: (value) {
          if (value.isEmpty) {
            return "App's name cannot be empty";
          }

          return null;
        },
      ),
    );
  }

  Widget appDescInput() {
    return SizedBox(
      width: 300.0,
      child: TextFormField(
        initialValue: appDesc,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          icon: Icon(Icons.featured_play_list_outlined),
          labelText: "App's description",
        ),
        onChanged: (value) {
          appDesc = value;
        },
        onFieldSubmitted: (value) => saveAppName(),
      ),
    );
  }

  Widget appNameEditCard() {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              appNameInput(),
              appDescInput(),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  isEditingAppName = false;
                  appName = '';
                  appDesc = '';
                  cardHeight = 160.0;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Text("Cancel"),
              ),
              style: TextButton.styleFrom(
                primary: Colors.white,
              ),
            ),
            ElevatedButton(
              onPressed: saveAppName,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget appPresentation() {
    double horPadding = 90.0;

    if (MediaQuery.of(context).size.width < Constants.maxMobileWidth) {
      horPadding = 0.0;
    }

    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Padding(
          padding: EdgeInsets.only(
            left: horPadding,
            right: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              appNameCard(),
              appIdCard(),
              apiKeysCard(),
              appStats(),
            ],
          ),
        ),
      ]),
    );
  }

  Widget appStats() {
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "All time API calls",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18.0,
                ),
              ),
              Opacity(
                opacity: 0.6,
                child: Text(
                  "${userApp.stats.calls.allTime}",
                  style: TextStyle(
                    fontWeight: FontWeight.w200,
                    fontSize: 24.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
              ),
              Text(
                "All calls limit",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18.0,
                ),
              ),
              Opacity(
                opacity: 0.6,
                child: Text(
                  "${userApp.stats.calls.callsLimit}",
                  style: TextStyle(
                    fontWeight: FontWeight.w200,
                    fontSize: 24.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget body({double screenWidth}) {
    if (isLoading) {
      return loadingView();
    }

    if (userApp == null) {
      return emptyView();
    }

    return appPresentation();
  }

  Widget emptyView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        FadeInY(
          delay: 100.milliseconds,
          beginY: 50.0,
          child: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: EmptyContent(
              icon: Opacity(
                opacity: .8,
                child: Icon(
                  UniconsLine.apps,
                  size: 60.0,
                  color: Color(0xFFFF005C),
                ),
              ),
              title: Opacity(
                opacity: 0.8,
                child: Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: Text(
                    "You have no apps",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25.0,
                    ),
                  ),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    "You can create a new one",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget loadingView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: LoadingAnimation(
            textTitle: 'Loading app data...',
          ),
        ),
      ]),
    );
  }

  void deleteApp(UserApp app) async {
    setState(() => isLoading = true);

    showSnack(
      context: context,
      type: SnackType.success,
      message: "The app ${app.name} has been deleted.",
    );

    try {
      final callable = CloudFunctions(
        app: Firebase.app(),
        region: 'europe-west3',
      ).getHttpsCallable(
        functionName: 'developers-deleteApp',
      );

      final response = await callable.call({
        'appId': app.id,
      });

      final deleteData = RequestAppResponse.fromJSON(response.data);

      setState(() => isLoading = false);

      if (!deleteData.success) {
        showSnack(
          context: context,
          type: SnackType.error,
          message: "There was an error while deleting your app ${app.name}. "
              "Please try again later or contact the support.",
        );
      }

      context.router.root.navigate(
        DashboardPageRoute(children: [MyAppsRoute()]),
      );
    } on CloudFunctionsException catch (exception) {
      debugPrint("[code: ${exception.code}] - ${exception.message}");
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void fetch() async {
    setState(() => isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('apps')
          .doc(widget.appId)
          .get();

      final data = snapshot.data();

      if (!snapshot.exists || data == null) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      data['id'] = snapshot.id;

      setState(() {
        isLoading = false;
        userApp = UserApp.fromJSON(data);
      });
    } catch (error) {
      setState(() => isLoading = false);
      debugPrint(error.toString());

      showSnack(
        context: context,
        message: "There was an issue while fetching the app's data.",
        type: SnackType.error,
      );
    }
  }

  void saveAppName() async {
    if (userApp == null) {
      return;
    }

    if (appName == null || appName.isEmpty) {
      showSnack(
        context: context,
        type: SnackType.error,
        message: "Please provid a valid app's name. Value cannot be empty.",
      );

      return;
    }

    final prevName = userApp.name;
    final prevDesc = userApp.description;

    setState(() {
      cardHeight = 160.0;
      isEditingAppName = false;
      userApp.name = appName;
      userApp.description = appDesc;
    });

    showSnack(
      context: context,
      type: SnackType.success,
      message: "Your app's metadata has been saved.",
    );

    try {
      final callable = CloudFunctions(
        app: Firebase.app(),
        region: 'europe-west3',
      ).getHttpsCallable(
        functionName: 'developers-updateAppMetadata',
      );

      final response = await callable.call({
        'appId': userApp.id,
        'name': appName,
        'description': appDesc,
      });

      final updatedData = RequestAppResponse.fromJSON(response.data);

      if (!updatedData.success) {
        setState(() {
          userApp.name = prevName;
          userApp.description = prevDesc;
        });

        showSnack(
          context: context,
          type: SnackType.error,
          message: "There was an error while editing your app ${userApp.name}. "
              "Please try again later or contact the support.",
        );
      }
    } on CloudFunctionsException catch (exception) {
      debugPrint("[code: ${exception.code}] - ${exception.message}");
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
