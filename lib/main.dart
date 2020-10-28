import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:figstyle/actions/users.dart';
import 'package:figstyle/components/full_page_loading.dart';
import 'package:figstyle/main_app.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/topics_colors.dart';
import 'package:figstyle/state/user_state.dart';
import 'package:figstyle/utils/app_localstorage.dart';

void main() async {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  return runApp(App());
}

class App extends StatefulWidget {
  AppState createState() => AppState();
}

class AppState extends State<App> {
  bool isReady = false;

  AppState();

  @override
  void initState() {
    super.initState();

    appLocalStorage.initialize().then((value) {
      final savedLang = appLocalStorage.getLang();
      userState.setLang(savedLang);

      autoLogin();

      setState(() {
        isReady = true;
      });
    });

    appTopicsColors.fetchTopicsColors();
  }

  @override
  Widget build(BuildContext context) {
    if (isReady) {
      return DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => ThemeData(
          fontFamily: GoogleFonts.raleway().fontFamily,
          brightness: brightness,
        ),
        themedWidgetBuilder: (context, theme) {
          stateColors.themeData = theme;
          return MainApp();
        },
      );
    }

    return MaterialApp(
      title: 'fig.style',
      home: Scaffold(
        body: FullPageLoading(),
      ),
    );
  }

  void autoLogin() async {
    try {
      final credentials = appLocalStorage.getCredentials();

      if (credentials == null) {
        return;
      }

      final email = credentials['email'];
      final password = credentials['password'];

      if ((email == null || email.isEmpty) ||
          (password == null || password.isEmpty)) {
        return;
      }

      final authResult = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (authResult.user == null) {
        return;
      }

      appLocalStorage.setUserName(authResult.user.displayName);
      await userGetAndSetAvatarUrl(authResult);

      userState.setUserConnected();
      userState.setUserName(authResult.user.displayName);
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
