import 'package:flutter/material.dart';
import 'package:messeapp/main.dart';
import 'package:messeapp/registro/loginRegistro.dart';
import 'package:messeapp/registro/votiRegistro.dart';
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
  static String token;
  TabController _controller;
  static String username;

  @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> log (String token, String username, String password) async {
    if (token == null) return;
    await PrefService.setString(USERNAME_KEY, username);
    await PrefService.setString(PASSWORD_KEY, password);

    setState(() {
      RegistroState.token = token;
      RegistroState.username = username;
      logged = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!logged) return LoginRegistro(this);
    TabBar bar = TabBar(
        controller: _controller,
        tabs: [
          Tab(text: "VOTI"),
          Tab(text: "LEZIONI"),
          Tab(text: "AGENDA")
        ]
    );
    TabBarView view = TabBarView(
        controller: _controller,
        children: [
          MarksRegistro(token, username),
          Center (child: Text("LEZIONI")),
          Center (child: Text("AGENDA"))
        ]
    );
    return Scaffold(
      appBar: bar,  // FIXME: la bar dovrebbe essere infilata nella AppBar dello Scaffold principale
      body: view,
    );
  }

}