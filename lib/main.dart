import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:relines/router/app_router.gr.dart';
import 'package:relines/router/auth_guard.dart';
import 'package:relines/router/no_auth_guard.dart';
import 'package:relines/state/colors.dart';
import 'package:relines/state/topics_colors.dart';
import 'package:relines/state/user.dart';
import 'package:relines/types/topic_color.dart';
import 'package:relines/utils/app_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supercharged/supercharged.dart';

void main() async {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await appStorage.initialize();
  await Future.wait([_autoLogin(), _initColors()]);
  runApp(App());
}

class App extends StatefulWidget {
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
    final brightness = getBrightness();
    stateColors.refreshTheme(brightness);

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
      initial: brightness == Brightness.light
          ? AdaptiveThemeMode.light
          : AdaptiveThemeMode.dark,
      builder: (theme, darkTheme) {
        stateColors.themeData = theme;

        return MaterialApp.router(
          title: 'Did I Say?',
          theme: stateColors.themeData,
          darkTheme: darkTheme,
          debugShowCheckedModeBanner: false,
          routerDelegate: appRouter.delegate(),
          routeInformationParser: appRouter.defaultRouteParser(),
        );
      },
    );
  }

  Brightness getBrightness() {
    final autoBrightness = appStorage.getAutoBrightness();

    if (!autoBrightness) {
      return appStorage.getBrightness();
    }

    Brightness brightness = Brightness.light;
    final now = DateTime.now();

    if (now.hour < 6 || now.hour > 17) {
      brightness = Brightness.dark;
    }

    return brightness;
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
