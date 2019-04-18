import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;

class LoginRegistro extends StatefulWidget{
  static const String API_KEY = "Tg1NWEwNGIgIC0K";

  /// funzione per prelevare il 'token' da utilizzare per mantenere la sessione
  /// controllo di username e password
  static Future<String> makeLogin (BuildContext context, String username, String password) async {
    Map<String, String> head = {
      "Z-Dev-Apikey": API_KEY,
      "Content-Type": "application/json",
      "User-Agent": "CVVS/std/1.7.9 Android/6.0)"
    };
    String data = "{\"ident\":null,\"pass\":\"$password\",\"uid\":\"$username\"}";
    http.Response r;
    try{
      r = await http.post('https://web.spaggiari.eu/rest/v1/auth/login', headers: head, body: data);
    } catch(SocketException){
      Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("Controlla la connessione ad internet"),
            action: SnackBarAction(label: "RIPROVA", onPressed: () => makeLogin(context, username, password),),
          )
      );
      return null;
    }
    var json = jsonDecode(r.body);

    if (r.statusCode != 200) {
      Scaffold.of(context).showSnackBar(
        SnackBar(content: Text(json["info"]))
      );
      return null;
    }

    Scaffold.of(context).showSnackBar(
        SnackBar(content: Text(
            'Benvenuto ${json["firstName"]} ${json["lastName"]}'
        ))
    );


    String token = json["token"];

    /* esempio per le richieste successive (get non post)
    head = {
      "Z-Dev-Apikey": API_KEY,
      "Content-Type": "application/json",
      "User-Agent": "CVVS/std/1.7.9 Android/6.0)",
      "Z-Auth-Token": token
    };

    //test: working!
    r = await http.get('https://web.spaggiari.eu/rest/v1/students/${username.substring(1, username.length-1)}/cards', headers: head);
    print (r.body);
    json = jsonDecode(r.body);
    */

    return token;
  }

  @override
  State<LoginRegistro> createState() => RegistroState();
}


class RegistroState extends State<LoginRegistro> {

  @override
  Widget build(BuildContext context) {
    TextEditingController unameController = TextEditingController();
    TextEditingController pwordController = TextEditingController();
    TextFormField uname = TextFormField(
      controller: unameController,
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: InputDecoration(
          hintText: "username",
          contentPadding: EdgeInsets.all(10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          )
      ),
    );
    TextFormField pword = TextFormField(
      controller: pwordController,
      keyboardType: TextInputType.text,
      obscureText: true,
      decoration: InputDecoration(
          hintText: "password",
          contentPadding: EdgeInsets.all(10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30)
          )
      ),
    );

    Material btn = Material(
      borderRadius: BorderRadius.circular(30),
      shadowColor: Colors.black54,
      color: Colors.lightGreen[900],
      elevation: 5.0,
      child: MaterialButton(
        minWidth: 200.0,
        height: 42.0,
        onPressed: () {
          Future<String> token = LoginRegistro.makeLogin(context, unameController.text, pwordController.text);
          token.then((str) {
            if (str == null) return;
            //TODO: cambiare la schermata di login con quella dei voti/lezioni/agenda ecc
          });
        },
        //color: Colors.lightGreen[900],
        child: Text("LOGIN", style: TextStyle(color: Colors.white,),),
      ),
    );

    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.all(20),
      children: <Widget>[
        uname,
        SizedBox(height: 8),
        pword,
        SizedBox(height: 24),
        btn,
      ],
    );
  }
}