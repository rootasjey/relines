// export 'app_router.gr.dart';

import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:relines/router/auth_guard.dart';
import 'package:relines/router/no_auth_guard.dart';
import 'package:relines/screens/about.dart';
import 'package:relines/screens/changelog.dart';
import 'package:relines/screens/contact.dart';
import 'package:relines/screens/dashboard_page.dart';
import 'package:relines/screens/delete_account.dart';
import 'package:relines/screens/play.dart';
import 'package:relines/screens/update_username.dart';
import 'package:relines/screens/forgot_password.dart';
import 'package:relines/screens/home.dart';
import 'package:relines/screens/settings.dart';
import 'package:relines/screens/signin.dart';
import 'package:relines/screens/signup.dart';
import 'package:relines/screens/tos.dart';
import 'package:relines/screens/undefined_page.dart';
import 'package:relines/screens/update_email.dart';
import 'package:relines/screens/update_password.dart';

@MaterialAutoRouter(
  routes: <AutoRoute>[
    AutoRoute(path: '/', page: Home),
    AutoRoute(path: '/play', page: Play),
    MaterialRoute(path: '/about', page: About),
    MaterialRoute(path: '/changelog', page: Changelog),
    MaterialRoute(path: '/contact', page: Contact),
    AutoRoute(
      path: '/dashboard',
      page: DashboardPage,
      guards: [AuthGuard],
      children: [
        RedirectRoute(path: '', redirectTo: 'settings'),
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
            AutoRoute(
              path: 'update',
              page: EmptyRouterPage,
              name: 'AccountUpdateDeepRoute',
              children: [
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
