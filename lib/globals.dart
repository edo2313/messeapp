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
        icon: Icon(Icons.access_time), title: Text('Orari'))
  ];

  static BottomNavigationBar get bottomNavigationBar =>
      BottomNavigationBar(
        currentIndex: index,
        type: BottomNavigationBarType.fixed,
        items: navigationBarItems,
        onTap: (int i) => PrefService.setInt('last_opened_page', index = i),
      );
}