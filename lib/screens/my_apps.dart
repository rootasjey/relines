import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:relines/components/empty_content.dart';
import 'package:relines/components/fade_in_y.dart';
import 'package:relines/components/loading_animation.dart';
import 'package:relines/components/page_app_bar.dart';
import 'package:relines/components/sliver_edge_padding.dart';
import 'package:relines/router/app_router.gr.dart';
import 'package:relines/state/colors.dart';
import 'package:relines/state/user.dart';
import 'package:relines/types/request_app_response.dart';
import 'package:relines/types/enums.dart';
import 'package:relines/types/user_app.dart';
import 'package:relines/utils/app_storage.dart';
import 'package:relines/utils/constants.dart';
import 'package:relines/utils/snack.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class MyApps extends StatefulWidget {
  @override
  _MyAppsState createState() => _MyAppsState();
}

class _MyAppsState extends State<MyApps> {
  bool descending = true;
  bool hasNext = true;
  bool isFabVisible = false;
  bool isLoading = false;
  bool isLoadingMore = false;

  DocumentSnapshot lastDoc;

  final int limit = 30;

  ItemsLayout itemsLayout = ItemsLayout.list;

  List<UserApp> userApps = [];

  final ScrollController scrollController = ScrollController();
  final String pageRoute = MyAppsRoute.name;

  @override
  initState() {
    super.initState();
    initProps();
    fetch();
  }

  void initProps() {
    descending = appStorage.getPageOrder(pageRoute: pageRoute);
    itemsLayout = appStorage.getItemsStyle(pageRoute);
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

              // Load more scenario
              if (scrollNotif.metrics.pixels <
                  scrollNotif.metrics.maxScrollExtent - 100.0) {
                return false;
              }

              if (hasNext && !isLoadingMore) {
                fetchMore();
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
      descending: descending,
      onDescendingChanged: (newDescending) {
        if (descending == newDescending) {
          return;
        }

        descending = newDescending;
        fetch();

        appStorage.setPageOrder(
          descending: newDescending,
          pageRoute: pageRoute,
        );
      },
      itemsLayout: itemsLayout,
      onItemsLayoutSelected: (selectedLayout) {
        if (selectedLayout == itemsLayout) {
          return;
        }

        setState(() {
          itemsLayout = selectedLayout;
        });

        appStorage.saveItemsStyle(
          pageRoute: pageRoute,
          style: selectedLayout,
        );
      },
      additionalIconButtons: [
        IconButton(
          tooltip: "Create a new app",
          onPressed: () {
            context.router.root.push(
              DashboardPageRoute(children: [CreateAppRoute()]),
            );
          },
          icon: Icon(UniconsLine.create_dashboard),
        ),
      ],
    );
  }

  Widget body({double screenWidth}) {
    if (isLoading) {
      return loadingView();
    }

    if (userApps.length == 0) {
      return emptyView();
    }

    final Widget sliver =
        itemsLayout == ItemsLayout.list ? listView() : gridView();

    return SliverPadding(
      padding: const EdgeInsets.only(top: 24.0),
      sliver: sliver,
    );
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

  Widget gridView() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300.0,
          crossAxisSpacing: 20.0,
          mainAxisSpacing: 20.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final userApp = userApps.elementAt(index);

            return Container(
              width: 500.0,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(children: [
                    Text(
                      userApp.name,
                    )
                  ]),
                ),
              ),
            );
          },
          childCount: userApps.length,
        ),
      ),
    );
  }

  Widget listView() {
    double horPadding = 70.0;

    if (MediaQuery.of(context).size.width < Constants.maxMobileWidth) {
      horPadding = 0.0;
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final userApp = userApps.elementAt(index);

          return Container(
            width: 400.0,
            padding: EdgeInsets.symmetric(horizontal: horPadding),
            child: Card(
              elevation: 2.0,
              child: InkWell(
                onTap: () {
                  AppPageRoute(appId: userApp.id).show(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userApp.name,
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Opacity(
                              opacity: 0.6,
                              child: Text(
                                userApp.description,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        color: Colors.pink,
                        onPressed: () => deleteApp(userApp),
                        icon: Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        childCount: userApps.length,
      ),
    );
  }

  Widget loadingView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: LoadingAnimation(
            textTitle: 'Loading your apps...',
          ),
        ),
      ]),
    );
  }

  void fetch() async {
    setState(() {
      isLoading = true;
      userApps.clear();
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('apps')
          .where('user.id', isEqualTo: stateUser.userAuth.uid)
          .orderBy('createdAt', descending: descending)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          isLoading = false;
          hasNext = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final quote = UserApp.fromJSON(data);
        userApps.add(quote);
      });

      lastDoc = snapshot.docs.last;

      setState(() {
        isLoading = false;
        hasNext = limit == snapshot.docs.length;
      });
    } catch (error) {
      setState(() => isLoading = false);
      debugPrint(error.toString());

      showSnack(
        context: context,
        message: 'There was an issue while fetching your favourites.',
        type: SnackType.error,
      );
    }
  }

  void fetchMore() async {
    setState(() => isLoadingMore = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('apps')
          .where('user.id', isEqualTo: stateUser.userAuth.uid)
          .orderBy('createdAt', descending: descending)
          .startAfterDocument(lastDoc)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          hasNext = false;
          isLoadingMore = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final quote = UserApp.fromJSON(data);
        userApps.add(quote);
      });

      lastDoc = snapshot.docs.last;

      setState(() {
        isLoadingMore = false;
        hasNext = limit == snapshot.docs.length;
      });
    } catch (error) {
      setState(() => isLoading = false);
      debugPrint(error.toString());

      showSnack(
        context: context,
        message: 'There was an issue while fetching your favourites.',
        type: SnackType.error,
      );
    }
  }

  void deleteApp(UserApp app) async {
    setState(() {
      userApps.remove(app);
    });

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

      if (!deleteData.success) {
        setState(() {
          userApps.add(app);
        });

        showSnack(
          context: context,
          type: SnackType.error,
          message: "There was an error while deleting your app ${app.name}. "
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
