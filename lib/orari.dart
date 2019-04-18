import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Orari extends StatefulWidget{

  // funzione per caricare i link delle immagini
  Future<Map<String, String>> loadLinks () async {
    Map<String,MapEntry<String, String>> classCode = Map();
    String currentyear =  (DateTime.now().year-1).toString()+'-'+DateTime.now().year.toString().substring(2,4); //Prende dinamicamente l'anno attuale per cambiare il link
    http.Response r = await http.get('https://www.messedaglia.gov.it/images/stories/$currentyear/orario/_ressource.js');
    if (r.statusCode != 200) return null;
    List<String> lines = r.body.split('\n');
    for (String str in lines){
      if (!str.startsWith("listeRessources")) continue;
      str = str.substring(str.indexOf("(")+1, str.indexOf(")"));
      List<String> split = str.split(',');
      if (split.last == "\"vide\"") continue;
      classCode.putIfAbsent(split[2].substring(1,split[2].length-1), () => MapEntry(split[1].substring(1,split[1].length-1),""));
    }
    
    r = await http.get('https://www.messedaglia.gov.it/images/stories/$currentyear/orario/_periode.js');
    if (r.statusCode != 200) return null;
    lines = r.body.split('\n');
    for (String str in lines){
      if (!str.startsWith("listePeriodes")) continue;
      str = str.substring(str.indexOf("(")+1, str.indexOf(")"));
      List<String> split = str.split(',');
      classCode.update(split[0].substring(1,split[0].length-1), (e) => MapEntry(e.key, 'https://www.messedaglia.gov.it/images/stories/$currentyear/orario/classi/${split[2].substring(1,split[2].length-1)}.png'));
    }
    return Map<String,String>.fromEntries(classCode.values);
  }

  @override
  State<Orari> createState() => OrariState();

}

class OrariState extends State<Orari> {
  String link;
  String cls;
  Map<String, String> orari;

  @override
  Widget build(BuildContext context) {
    if (orari == null){
      widget.loadLinks().then((m) {
        orari = m;
        setState(() {});
      });
      return Center(child: new CircularProgressIndicator(),);  // provvisorio
    }
    DropdownButton<String> picker = DropdownButton( // TODO: cambiare lo stile
      value: cls,
      items: orari.keys.map((str) => DropdownMenuItem(child: Text(str), value: str)).toList(),
      onChanged: (str) => setState(() {
        link = orari[str];
        cls = str;
      }),
      isExpanded: true,
      hint: Text('Scegli la classe'),
    );
    return Column(
      children: <Widget>[picker, link!=null?Image.network(link):Container()],
    );
  }

}