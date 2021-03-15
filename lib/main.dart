import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:relines/router/app_router.gr.dart';
import 'package:relines/router/no_auth_guard.dart';
import 'package:relines/state/colors.dart';
import 'package:relines/state/game.dart';
import 'package:relines/state/topics_colors.dart';
import 'package:relines/state/user.dart';
import 'package:relines/types/topic_color.dart';
import 'package:relines/utils/app_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relines/utils/brightness.dart';
import 'package:supercharged/supercharged.dart';
import 'package:url_strategy/url_strategy.dart';

import 'router/auth_guard.dart';

void main() async {
  setPathUrlStrategy();

  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await appStorage.initialize();
  await GlobalConfiguration().loadFromPath("config/base.json");
  await Future.wait([_autoLogin(), _initColors()]);
  await EasyLocalization.ensureInitialized();

  Game.setLanguage(appStorage.getLang());

  final brightness = BrightnessUtils.getCurrent();

  final savedThemeMode = brightness == Brightness.dark
      ? AdaptiveThemeMode.dark
      : AdaptiveThemeMode.light;

  runApp(EasyLocalization(
    path: 'assets/translations',
    supportedLocales: [Locale('en'), Locale('fr')],
    fallbackLocale: Locale('en'),
    child: App(
      savedThemeMode: savedThemeMode,
      brightness: brightness,
    ),
  ));
}

class App extends StatefulWidget {
  final AdaptiveThemeMode savedThemeMode;
  final Brightness brightness;

  const App({
    Key key,
    this.savedThemeMode,
    this.brightness,
  }) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final appRouter = AppRouter(
    authGuard: AuthGuard(),
    noAuthGuard: NoAuthGuard(),
  );

  @override
  Widget build(BuildContext context) {
    stateColors.refreshTheme(widget.brightness);

    return AdaptiveTheme(
      light: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.red,
        accentColor: Colors.amber,
        fontFamily: GoogleFonts.ptSans().fontFamily,
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        accentColor: Colors.amber,
        fontFamily: GoogleFonts.ptSans().fontFamily,
      ),
      initial: widget.brightness == Brightness.light
          ? AdaptiveThemeMode.light
          : AdaptiveThemeMode.dark,
      builder: (theme, darkTheme) {
        stateColors.themeData = theme;

        return AppWithTheme(
          brightness: widget.brightness,
          theme: theme,
          darkTheme: darkTheme,
        );
      },
    );
  }
}

/// Because we need a [context] with adaptive theme data available in it.
class AppWithTheme extends StatefulWidget {
  final ThemeData theme;
  final ThemeData darkTheme;
  final Brightness brightness;

  const AppWithTheme({
    Key key,
    @required this.brightness,
    @required this.darkTheme,
    @required this.theme,
  }) : super(key: key);

  @override
  _AppWithThemeState createState() => _AppWithThemeState();
}

class _AppWithThemeState extends State<AppWithTheme> {
  final appRouter = AppRouter(
    authGuard: AuthGuard(),
    noAuthGuard: NoAuthGuard(),
  );

  @override
  initState() {
    super.initState();
    Future.delayed(250.milliseconds, () {
      if (widget.brightness == Brightness.dark) {
        AdaptiveTheme.of(context).setDark();
        return;
      }

      AdaptiveTheme.of(context).setLight();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Relines',
      theme: widget.theme,
      darkTheme: widget.darkTheme,
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      routerDelegate: appRouter.delegate(),
      routeInformationParser: appRouter.defaultRouteParser(),
    );
  }
}

// Initialization functions.
// ------------------------
Future _autoLogin() async {
  try {
    final userCred = await stateUser.signin();

    if (userCred == null) {
      stateUser.signOut();
    }
  } catch (error) {
    debugPrint(error.toString());
    stateUser.signOut();
  }
}

Future _initColors() async {
  await appTopicsColors.fetchTopicsColors();

  final color = appTopicsColors.shuffle(max: 1).firstOrElse(
        () => TopicColor(
          name: 'blue',
          decimal: Colors.blue.value,
          hex: Colors.blue.value.toRadixString(16),
        ),
      );

  stateColors.setAccentColor(Color(color.decimal));
}
