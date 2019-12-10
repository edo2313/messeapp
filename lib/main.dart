import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:package_info/package_info.dart';
import 'package:messeapp/registro/registro.dart';
import 'package:messeapp/orari.dart';
import 'package:messeapp/splashScreen.dart';
import 'package:messeapp/settings.dart';
import 'package:messeapp/globals.dart';
import 'package:messeapp/deskEditor.dart';
import 'package:android_intent/android_intent.dart';

import 'package:http/http.dart' as http;

Future<void> main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  
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
    return new DynamicTheme(
        defaultBrightness: (PrefService.getBool('darkmode')??false)
            ? Brightness.dark
            : Brightness.light,
        data: (brightness) => new ThemeData(
              primarySwatch: Glob.primarySwatch,
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
  static bool updateShowed = false;

  @override
  void initState() {
    Glob.splashCallback = () => setState((){});
    Glob.indexCallback = () => setState((){});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    // dialog provvisorio per il testing
    // ad ogni aggiornamento bisogna incrementare il versionName in app/build.gradle, da ripristinare alla release
    if (!updateShowed) {
      Future<http.Response> fr = http.get('https://raw.githubusercontent.com/edo-2313/messeapp/master/android/app/build.gradle');
      fr.then((r) async {
        int index = r.body.indexOf('def flutterVersionName =');
        index = r.body.indexOf('\'', index);
        String version = r.body.substring(
            index + 1, r.body.indexOf('\'', index + 1));
        String currentVersion = (await PackageInfo.fromPlatform()).version;
        //print ((await PackageInfo.fromPlatform()).version);
        if (version != currentVersion && !updateShowed) {
          updateShowed = true;
          showDialog(
              context: context,
              builder: (context) =>
                  AlertDialog(
                    title: Text('NUOVO AGGIORNAMENTO DISPONIBILE'),
                    content: Text(
                        'È disponibile la versione $version al posto della versione $currentVersion\n' +
                            'La nuova versione potrebbe non essere disponibile subito dopo il commit!'),
                    /*actions: <Widget>[
                    MaterialButton(
                      child: Text('AGGIORNA'),
                      onPressed: () => AndroidIntent(
                        action: 'android.intent.action.WEB_SEARCH',
                        data: 'https://cloud.edo2313.tk/index.php/s/lcK6tnZcnqdKyjq',

                      ).launch(),
                    )
                  ],*/
                  ).build(context)
          );
        }
        //version = int.parse(r.body.substring(version, r.body.indexOf('\'', version+1)));
        //print (version);
      });
    }

    if (Glob.showSplash) return SplashScreen();
    else return buildBody(context);
  }

  Widget buildBody(BuildContext context) {
    switch (Glob.index) {
      case 0:
        return Registro(this);
      case 2:
        return Orari();
      case 3:
        return Scaffold(
          backgroundColor: Colors.grey, // per far risaltare la canvas
          body: Center(
              child: new Container(
                height: 210.0,
                width: 300.0,
                child: new CustomPaint(
                  painter: DeskEditor(),
                  size: Size(300, 210), // dimensione provvisoria
                ),
              )
          ),
          bottomNavigationBar: Glob.bottomNavigationBar,
        );
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
