import 'package:flutter/material.dart';
import 'package:messeapp/main.dart';
import 'package:messeapp/registro/loginRegistro.dart';
import 'package:messeapp/registro/votiRegistro.dart';
import 'package:messeapp/settings.dart';
import 'package:messeapp/globals.dart';
import 'package:preferences/preferences.dart';

const String API_KEY = "Tg1NWEwNGIgIC0K";
const String USERNAME_KEY = 'CVVS_UNAME';
const String PASSWORD_KEY = 'CVVS_PWORD';
const String AUTO_LOGIN_KEY = 'REG_AUTO_LOGIN';

class Registro extends StatefulWidget {
  final MyHomePageState home;

  Registro (this.home);

  @override
  RegistroState createState() {
    return RegistroState();
  }
}

class RegistroState extends State<Registro> with SingleTickerProviderStateMixin{
  static bool logged = false;
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: 3);
    bool autoLogin = PrefService.get(AUTO_LOGIN_KEY) ?? true;

    if (autoLogin)
      if (((PrefService.get(USERNAME_KEY)??'') != '') && ((PrefService.get(PASSWORD_KEY)??'') != ''))
        logged = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> log (String username, String password, {bool saveCredentials: true}) async {
    if (saveCredentials) {
      await PrefService.setString(USERNAME_KEY, username);
      await PrefService.setString(PASSWORD_KEY, password);
    }

    setState(() => logged = true);
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (!logged) body = LoginRegistro(this);
    else body = TabBarView(
        controller: _controller,
        children: [MarksRegistro(), Center (child: Text("LEZIONI")), Center (child: Text("AGENDA"))]
    );
    TabBar bar = TabBar(
        controller: _controller,
        tabs: [Tab(text: "VOTI"), Tab(text: "LEZIONI"), Tab(text: "AGENDA")]
    );
    return Scaffold(
      appBar: AppBar(
        leading: ImageIcon(AssetImage('assets/logomesse.png')),
        title: Text('MesseApp'),
        bottom: logged? bar:null,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Settings()),
              );
            },
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: Glob.bottomNavigationBar,
    );
  }

}