import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:messeapp/globals.dart';
import 'package:messeapp/settings.dart';
import 'dart:convert';
import 'package:preferences/preferences.dart';

const DATA_KEY = 'ORARI_DATA';

class Orari extends StatefulWidget {
  // funzione per controllare se esistono orari nuovi

  static Future<int> checkNewLink() async {
    int currentyear = DateTime.now().year;
    String nextyear = '$currentyear-${(currentyear+1)%100}';
    http.Response response;
    try {
      response = await http.get('https://www.messedaglia.gov.it/images/stories/$nextyear/orario/');
    } catch (e){
      return null;
    }
    if (response.statusCode == 200) return currentyear;
    if (response.statusCode == 404) return currentyear-1;
    // TODO: gestire le eccezioni
    return null;
  }

  // funzione per caricare i link delle immagini

  static Future<void> loadLinks() async {
    Map<String, MapEntry<String, String>> classCode = Map();
    int currentyear = await checkNewLink();
    if (currentyear == null) return;
    String year = '$currentyear-${(currentyear+1)%100}';
    http.Response r = await http.get('https://www.messedaglia.gov.it/images/stories/$year/orario/_ressource.js');
    if (r.statusCode != 200) return;
    List<String> lines = r.body.split('\n');
    for (String str in lines) {
      if (!str.startsWith("listeRessources")) continue;
      str = str.substring(str.indexOf("(") + 1, str.indexOf(")"));
      List<String> split = str.split(',');
      if (split.last == "\"vide\"") continue;
      classCode.putIfAbsent(split[2].substring(1, split[2].length - 1),
              () => MapEntry(split[1].substring(1, split[1].length - 1), ""));
    }

    r = await http.get('https://www.messedaglia.gov.it/images/stories/$year/orario/_periode.js');
    if (r.statusCode != 200) return;
    lines = r.body.split('\n');
    for (String str in lines) {
      if (!str.startsWith("listePeriodes")) continue;
      str = str.substring(str.indexOf("(") + 1, str.indexOf(")"));
      List<String> split = str.split(',');
      classCode.update(
          split[0].substring(1, split[0].length - 1),
              (e) => MapEntry(e.key,
              'https://www.messedaglia.gov.it/images/stories/$year/orario/classi/${split[2].substring(1, split[2].length - 1)}.png'));
    }

    // TODO: la funzione non deve ritornare nulla, deve salvare i dati sul db locale (o sharedPreferences come stringa json)

    String json = jsonEncode(Map<String, String>.fromEntries(classCode.values));
    PrefService.setString(DATA_KEY, json);
  }

  @override
  State<Orari> createState() => OrariState();
}

class OrariState extends State<Orari> {
  static String cls;
  static String link;
  static Map<String, dynamic> orari;


  @override
  void initState() {
    super.initState();
    if (orari == null) orari = jsonDecode(PrefService.getString(DATA_KEY));
    cls ??= PrefService.getString('orari_selected_class');
    link = orari[cls];
  }

  @override
  Widget build(BuildContext context) {
    DropdownButton<String> picker = DropdownButton(
      // TODO: cambiare lo stile
      value: cls,
      items: orari.keys
          .map((str) => DropdownMenuItem(child: Text(str), value: str))
          .toList(),
      onChanged: (str) => setState(() {
        link = orari[str];
        PrefService.setString('orari_selected_class', cls = str);

      }),
      isExpanded: true,
      hint: Text('Scegli la classe'),
    );
    return Scaffold(
      appBar: AppBar(
        leading: Glob.appbarLogo,
        title: Glob.appbarTitle,
        bottom: PreferredSize(
            child: Padding(
                child: picker, padding: EdgeInsets.symmetric(horizontal: 10)),
            preferredSize: Size.fromHeight(48.0)),
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
      body: link != null ? Image.network(link) : Container(),
      bottomNavigationBar: Glob.bottomNavigationBar,
    );
  }
}