// export 'app_router.gr.dart';

import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:disfigstyle/screens/about.dart';
import 'package:disfigstyle/screens/changelog.dart';
import 'package:disfigstyle/screens/contact.dart';
import 'package:disfigstyle/screens/home.dart';
import 'package:disfigstyle/screens/tos.dart';
import 'package:disfigstyle/screens/undefined_page.dart';

@MaterialAutoRouter(
  routes: <AutoRoute>[
    AutoRoute(path: '/', page: Home),
    MaterialRoute(path: '/about', page: About),
    MaterialRoute(path: '/changelog', page: Changelog),
    MaterialRoute(path: '/contact', page: Contact),
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
