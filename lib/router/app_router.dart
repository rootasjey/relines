// export 'app_router.gr.dart';

import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:disfigstyle/router/auth_guard.dart';
import 'package:disfigstyle/router/no_auth_guard.dart';
import 'package:disfigstyle/screens/about.dart';
import 'package:disfigstyle/screens/app_page.dart';
import 'package:disfigstyle/screens/changelog.dart';
import 'package:disfigstyle/screens/contact.dart';
import 'package:disfigstyle/screens/create_app.dart';
import 'package:disfigstyle/screens/dashboard_page.dart';
import 'package:disfigstyle/screens/deactivate_dev_prog.dart';
import 'package:disfigstyle/screens/delete_account.dart';
import 'package:disfigstyle/screens/forgot_password.dart';
import 'package:disfigstyle/screens/home.dart';
import 'package:disfigstyle/screens/my_apps.dart';
import 'package:disfigstyle/screens/settings.dart';
import 'package:disfigstyle/screens/signin.dart';
import 'package:disfigstyle/screens/signup.dart';
import 'package:disfigstyle/screens/tos.dart';
import 'package:disfigstyle/screens/undefined_page.dart';
import 'package:disfigstyle/screens/update_email.dart';
import 'package:disfigstyle/screens/update_password.dart';
import 'package:disfigstyle/screens/update_username.dart';

@MaterialAutoRouter(
  routes: <AutoRoute>[
    AutoRoute(path: '/', page: Home),
    MaterialRoute(path: '/about', page: About),
    MaterialRoute(path: '/changelog', page: Changelog),
    MaterialRoute(path: '/contact', page: Contact),
    AutoRoute(
      path: '/dashboard',
      page: DashboardPage,
      guards: [AuthGuard],
      children: [
        RedirectRoute(path: '', redirectTo: 'apps'),
        AutoRoute(
          path: 'apps',
          page: EmptyRouterPage,
          name: 'AppsDeepRoute',
          children: [
            AutoRoute(path: '', page: MyApps),
            AutoRoute(path: ':appId', page: AppPage),
          ],
        ),
        AutoRoute(path: 'create/app', page: CreateApp),
        AutoRoute(
          path: 'settings',
          page: EmptyRouterPage,
          name: 'DashboardSettingsDeepRoute',
          children: [
            MaterialRoute(
              path: '',
              page: Settings,
              name: 'DashboardSettingsRoute',
            ),
            AutoRoute(path: 'delete/account', page: DeleteAccount),
            AutoRoute(path: 'developers/deactivate', page: DeactivateDevProg),
            AutoRoute(
              path: 'update',
              page: EmptyRouterPage,
              name: 'AccountUpdateDeepRoute',
              children: [
                // RedirectRoute(path: '', redirectTo: 'email'),
                MaterialRoute(path: 'email', page: UpdateEmail),
                MaterialRoute(path: 'password', page: UpdatePassword),
                MaterialRoute(path: 'username', page: UpdateUsername),
              ],
            ),
          ],
        ),
      ],
    ),
    MaterialRoute(path: '/forgotpassword', page: ForgotPassword),
    MaterialRoute(path: '/settings', page: Settings),
    MaterialRoute(path: '/signin', page: Signin, guards: [NoAuthGuard]),
    MaterialRoute(path: '/signup', page: Signup, guards: [NoAuthGuard]),
    MaterialRoute(
      path: '/signout',
      page: EmptyRouterPage,
      name: 'SignOutRoute',
    ),
    AutoRoute(
      path: '/ext',
      page: EmptyRouterPage,
      name: 'ExtDeepRoute',
      children: [
        MaterialRoute(
          path: 'github',
          page: EmptyRouterPage,
          name: 'GitHubRoute',
        ),
      ],
    ),
    MaterialRoute(path: '/tos', page: Tos),
    MaterialRoute(path: '*', page: UndefinedPage),
  ],
)
class $AppRouter {}
