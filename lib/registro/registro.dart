import 'package:flutter/material.dart';
import 'package:messeapp/main.dart';
import 'package:messeapp/registro/loginRegistro.dart';
import 'package:messeapp/registro/votiRegistro.dart';

const String API_KEY = "Tg1NWEwNGIgIC0K";

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

  void log (String token){
    if (token == null) return;
    setState(() {
      RegistroState.token = token;
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