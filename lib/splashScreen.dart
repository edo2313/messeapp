import 'package:flutter/material.dart';
import 'package:messeapp/orari.dart';
import 'package:messeapp/registro/loginRegistro.dart';

class SplashScreen extends StatefulWidget{
  static _SplashScreenState state;

  static const List<Function> toLoad = [
    Orari.loadLinks,
    LoginRegistro.makeLogin,
    // mettere qui dentro le funzioni di caricamento dati
  ];

  @override
  _SplashScreenState createState() => state = _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int end = 0;
  void addEnd () => setState(() => end++);


  @override
  void initState() {
    Orari.loadLinks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/ic_launcher-web.png'),
      ),
      bottomSheet: Padding(
          padding: EdgeInsets.all(10),
          child: LinearProgressIndicator(
            value: end/SplashScreen.toLoad.length,
          )
      ),
    );
  }
}