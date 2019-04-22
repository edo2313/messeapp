import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

import 'package:messeapp/registro/registro.dart';
import 'package:messeapp/orari.dart';
import 'package:messeapp/splashScreen.dart';
import 'package:messeapp/settings.dart';
import 'package:messeapp/globals.dart';

Future<void> main() async {
  await PrefService.init(prefix: 'pref_');
  SplashScreen.toLoad.forEach((f) => f().then((x) {
    SplashScreen.state.addEnd();
    if (SplashScreen.state.end == SplashScreen.toLoad.length) Glob.showSplash = false;
  }));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    switch (PrefService.getString('start_page')) {
      case 'Mantieni l\'ultima pagina aperta':
        Glob.index = PrefService.getInt('last_opened_page') ?? 0;
        break;
      case 'Registro':
        Glob.index = 0;
        break;
      case 'Calendario':
        Glob.index = 1;
        break;
      case 'Orari':
        Glob.index = 2;
        break;
    }
    Map<int, Color> color = {
      50: Color.fromRGBO(245, 183, 69, .1),
      100: Color.fromRGBO(245, 183, 69, .2),
      200: Color.fromRGBO(245, 183, 69, .3),
      300: Color.fromRGBO(245, 183, 69, .4),
      400: Color.fromRGBO(245, 183, 69, .5),
      500: Color.fromRGBO(245, 183, 69, .6),
      600: Color.fromRGBO(245, 183, 69, .7),
      700: Color.fromRGBO(245, 183, 69, .8),
      800: Color.fromRGBO(245, 183, 69, .9),
      900: Color.fromRGBO(245, 183, 69, 1),
    };
    return new DynamicTheme(
        defaultBrightness: (PrefService.getBool('darkmode')??false)
            ? Brightness.dark
            : Brightness.light,
        data: (brightness) => new ThemeData(
              primarySwatch: MaterialColor(0xFFF5B745, color),
              appBarTheme: AppBarTheme(color: Color(0xFFF5B745)),
              brightness: brightness,
            ),
        themedWidgetBuilder: (context, theme) {
          return MaterialApp(
            title: 'MesseApp',
            theme: theme,
            home: new MyHomePage(title: 'MesseApp'),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  static MyHomePageState state;

  @override
  MyHomePageState createState() => state = MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int index = 0;

  Registro _registro;
  Orari _orari;

  @override
  void initState() {
    Glob.splashCallback = () => setState((){});
    Glob.indexCallback = () => setState((){});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Glob.showSplash) return SplashScreen();
    else return buildBody(context);
  }

  Widget buildBody(BuildContext context) {
    switch (Glob.index) {
      case 0:
        return (_registro ??= Registro(this));
      case 2:
        return (_orari ??= Orari());
      default:
        return Scaffold(
          body: Center(
            child: Text("PAGINA"),
          ),
          bottomNavigationBar: Glob.bottomNavigationBar,
        );
    }
  }
}
