import 'package:auto_route/auto_route.dart';
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
}
