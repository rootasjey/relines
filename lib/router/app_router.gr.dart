// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i1;
import '../screens/home.dart' as _i2;
import '../screens/about.dart' as _i3;
import '../screens/changelog.dart' as _i4;
import '../screens/contact.dart' as _i5;
import '../screens/tos.dart' as _i6;
import '../screens/undefined_page.dart' as _i7;

class AppRouter extends _i1.RootStackRouter {
  AppRouter();

  @override
  final Map<String, _i1.PageFactory> pagesMap = {
    HomeRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i2.Home());
    },
    AboutRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i3.About());
    },
    ChangelogRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i4.Changelog());
    },
    ContactRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i5.Contact());
    },
    SignOutRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    },
    ExtDeepRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    },
    TosRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i6.Tos());
    },
    UndefinedPageRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i7.UndefinedPage());
    },
    GitHubRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    }
  };

  @override
  List<_i1.RouteConfig> get routes => [
        _i1.RouteConfig<HomeRoute>(HomeRoute.name,
            path: '/', routeBuilder: (match) => HomeRoute.fromMatch(match)),
        _i1.RouteConfig<AboutRoute>(AboutRoute.name,
            path: '/about',
            routeBuilder: (match) => AboutRoute.fromMatch(match)),
        _i1.RouteConfig<ChangelogRoute>(ChangelogRoute.name,
            path: '/changelog',
            routeBuilder: (match) => ChangelogRoute.fromMatch(match)),
        _i1.RouteConfig<ContactRoute>(ContactRoute.name,
            path: '/contact',
            routeBuilder: (match) => ContactRoute.fromMatch(match)),
        _i1.RouteConfig<SignOutRoute>(SignOutRoute.name,
            path: '/signout',
            routeBuilder: (match) => SignOutRoute.fromMatch(match)),
        _i1.RouteConfig<ExtDeepRoute>(ExtDeepRoute.name,
            path: '/ext',
            routeBuilder: (match) => ExtDeepRoute.fromMatch(match),
            children: [
              _i1.RouteConfig<GitHubRoute>(GitHubRoute.name,
                  path: 'github',
                  routeBuilder: (match) => GitHubRoute.fromMatch(match))
            ]),
        _i1.RouteConfig<TosRoute>(TosRoute.name,
            path: '/tos', routeBuilder: (match) => TosRoute.fromMatch(match)),
        _i1.RouteConfig<UndefinedPageRoute>(UndefinedPageRoute.name,
            path: '*',
            routeBuilder: (match) => UndefinedPageRoute.fromMatch(match))
      ];
}

class HomeRoute extends _i1.PageRouteInfo {
  const HomeRoute() : super(name, path: '/');

  HomeRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'HomeRoute';
}

class AboutRoute extends _i1.PageRouteInfo {
  const AboutRoute() : super(name, path: '/about');

  AboutRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'AboutRoute';
}

class ChangelogRoute extends _i1.PageRouteInfo {
  const ChangelogRoute() : super(name, path: '/changelog');

  ChangelogRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'ChangelogRoute';
}

class ContactRoute extends _i1.PageRouteInfo {
  const ContactRoute() : super(name, path: '/contact');

  ContactRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'ContactRoute';
}

class SignOutRoute extends _i1.PageRouteInfo {
  const SignOutRoute() : super(name, path: '/signout');

  SignOutRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'SignOutRoute';
}

class ExtDeepRoute extends _i1.PageRouteInfo {
  const ExtDeepRoute({List<_i1.PageRouteInfo> children})
      : super(name, path: '/ext', initialChildren: children);

  ExtDeepRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'ExtDeepRoute';
}

class TosRoute extends _i1.PageRouteInfo {
  const TosRoute() : super(name, path: '/tos');

  TosRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'TosRoute';
}

class UndefinedPageRoute extends _i1.PageRouteInfo {
  const UndefinedPageRoute() : super(name, path: '*');

  UndefinedPageRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'UndefinedPageRoute';
}

class GitHubRoute extends _i1.PageRouteInfo {
  const GitHubRoute() : super(name, path: 'github');

  GitHubRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'GitHubRoute';
}
