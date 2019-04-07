import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;

class LoginRegistro {


  static Future<String> makeLogin (BuildContext context, String username, String password) async {
    Map<String, String> data = Map();
    data.putIfAbsent("uid", () => username);
    data.putIfAbsent("pwd", () => password);
    
    http.Response r = await http.post('https://web.spaggiari.eu/auth-p7/app/default/AuthApi4.php?a=aLoginPwd', body: data);
    print (r.headers);
    if (r.statusCode != 200){
      /*Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("Errore ${r.statusCode}!"),
            action: SnackBarAction(label: "RIPROVA", onPressed: () => makeLogin(context, username, password),),
          )
      );*/
      return null;
    }
    var json = jsonDecode(r.body);
    assert (json is Map);
    bool logged = json.values.elementAt(1).values.elementAt(0).values.elementAt(1);
    if (!logged) {
      /*Scaffold.of(context).showSnackBar(
        SnackBar(content: Text(
            json.values.elementAt(1).values.elementAt(0).values.elementAt(4).toString()
        ))
      );*/
      return null ;
    }
    String setCookies = r.headers.values.elementAt(2);
    print (setCookies);
    //set_cookies = set_cookies.substring(0, 42);
    setCookies = setCookies.substring(0, 42);
    print (setCookies);


    /* test: not working
    r = await http.get('https://web.spaggiari.eu/fml/app/default/regclasse_lezioni_xstudenti.php?action=loadLezioni&materia=201690&autori_id=505072', headers: {'Cookies': setCookies});
    dom.Document doc = parse(r.body);
    print (doc.children.elementAt(0).children.elementAt(1).children.elementAt(0).innerHtml);
    */
    return setCookies;
  }
}