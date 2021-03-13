import 'package:auto_route/auto_route.dart';
import 'package:relines/router/app_router.gr.dart';
import 'package:relines/state/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class NavigationHelper {
  static GlobalKey<NavigatorState> navigatorKey;

  static void navigateNextFrame(
    PageRouteInfo pageRoute,
    BuildContext context,
  ) {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      context.router.navigate(pageRoute);
    });
  }

  static PageRouteInfo getSettingsRoute() {
    if (stateUser.isUserConnected) {
      return DashboardPageRoute(children: [
        DashboardSettingsDeepRoute(children: [
          DashboardSettingsRoute(showAppBar: false),
        ])
      ]);
    }

    return SettingsRoute(showAppBar: true);
  }
}
