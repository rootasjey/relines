import 'package:auto_route/auto_route.dart';
import 'package:disfigstyle/router/app_router.gr.dart';
import 'package:disfigstyle/state/user.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  Future<bool> canNavigate(
    List<PageRouteInfo> pendingRoutes,
    StackRouter router,
  ) async {
    if (stateUser.isUserConnected) {
      return true;
    }

    router.root.push(
      SigninRoute(onSigninResult: (isAuthenticated) {
        if (isAuthenticated) {
          router.replaceAll(pendingRoutes);
        }
      }),
    );

    return false;
  }
}
