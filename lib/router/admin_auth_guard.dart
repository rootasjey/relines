import 'package:auto_route/auto_route.dart';
import 'package:relines/router/app_router.gr.dart';
import 'package:relines/state/user.dart';

class AdminAuthGuard extends AutoRouteGuard {
  @override
  Future<bool> canNavigate(
    List<PageRouteInfo> pendingRoutes,
    StackRouter router,
  ) async {
    if (stateUser.isUserConnected) {
      return true;
    }

    router.root.navigate(HomeRoute());
    return false;
  }
}
