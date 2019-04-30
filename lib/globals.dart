import 'package:flutter/material.dart';
import 'package:preferences/preference_service.dart';

class Glob {
  // sezione visibile
  static int _index = 0;
  static Function indexCallback;
  static int get index => _index;
  static set index(int index) {
    _index = index;
    if (indexCallback!=null) Function.apply(indexCallback, []);
  }

  // token per il registro
  static String token;

  // splash screen
  static bool _showSplash = true;
  static Function splashCallback;
  static bool get showSplash => _showSplash;
  static set showSplash(bool show) {
    _showSplash = show;
    if (splashCallback!=null) Function.apply(splashCallback, []);
  }

  // navigation bar items list
  static const List<BottomNavigationBarItem> navigationBarItems = [
    BottomNavigationBarItem(
        icon: Icon(Icons.vpn_key), title: Text('Registro')),
    BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today), title: Text('Calendario')),
    BottomNavigationBarItem(
        icon: Icon(Icons.access_time), title: Text('Orari')),
    BottomNavigationBarItem(
        icon: Icon(Icons.mode_edit), title: Text('Cambio Posti')),
  ];

  static BottomNavigationBar get bottomNavigationBar =>
      BottomNavigationBar(
        currentIndex: index,
        type: BottomNavigationBarType.fixed,
        items: navigationBarItems,
        onTap: (int i) => PrefService.setInt('last_opened_page', index = i),
      );

  // AppBar items
  static ImageIcon appbarLogo = ImageIcon(AssetImage('assets/logomesse.png'));
  static Text appbarTitle = Text('MesseApp');

  // primarySwatch
  static const MaterialColor primarySwatch = MaterialColor(
      0xFFF5B745,
      {
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
      }
  );
}