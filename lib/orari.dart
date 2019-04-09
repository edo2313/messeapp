import 'package:http/http.dart' as http;
import 'dart:io';

class Orari {

  static Future<Map<String, String>> loadLinks () async {
    Map<String, String> tr = Map();
    Map<String,MapEntry<String, String>> classCode = Map();
    http.Response r = await http.get('https://www.messedaglia.gov.it/images/stories/2018-19/orario/_ressource.js');
    if (r.statusCode != 200) return null;
    List<String> strs = r.body.split('\n');
    for (String str in strs){
      if (!str.startsWith("listeRessources")) continue;
      str = str.substring(str.indexOf("(")+1, str.indexOf(")"));
      List<String> split = str.split(',');
      if (split.last == "\"vide\"") continue;
      classCode.putIfAbsent(split[2].substring(1,split[2].length-1), () => MapEntry(split[1].substring(1,split[1].length-1),""));
    }
    
    r = await http.get('https://www.messedaglia.gov.it/images/stories/2018-19/orario/_periode.js');
    if (r.statusCode != 200) return null;
    strs = r.body.split('\n');
    for (String str in strs){
      if (!str.startsWith("listePeriodes")) continue;
      str = str.substring(str.indexOf("(")+1, str.indexOf(")"));
      List<String> split = str.split(',');
      classCode.update(split[0].substring(1,split[0].length-1), (e) => MapEntry(e.key, 'https://www.messedaglia.gov.it/images/stories/2018-19/orario/classi/${split[2].substring(1,split[2].length-1)}.png'));
    }

    for (MapEntry<String,String> e in classCode.values) tr.putIfAbsent(e.key, () => e.value);
    print(tr);
    return tr;
  }

}