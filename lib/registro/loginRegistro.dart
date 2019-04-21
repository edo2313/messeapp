import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:messeapp/registro/registro.dart';
import 'package:messeapp/main.dart';
import 'package:messeapp/registro/votiRegistro.dart';
import 'package:preferences/preferences.dart';



class LoginRegistro extends StatefulWidget{
  final RegistroState parent;

  LoginRegistro (this.parent);

  /// funzione per prelevare il 'token' da utilizzare per mantenere la sessione
  /// controllo di username e password
  static Future<String> makeLogin ([BuildContext context, String username, String password, bool wait = false]) async {
    username ??= PrefService.getString(USERNAME_KEY);
    password ??= PrefService.getString(PASSWORD_KEY);
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
      if (context == null) return null;
      Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("Controlla la connessione ad internet"),
            //action: SnackBarAction(label: "RIPROVA", onPressed: () {}),
          )
      );
      return null;
    }
    var json = jsonDecode(r.body);

    if (r.statusCode != 200) {
      if (context == null) return null;
      Scaffold.of(context).showSnackBar(
        SnackBar(content: Text(json["info"]))
      );
      return null;
    }
    if (context != null) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(
              'Benvenuto ${json["firstName"]} ${json["lastName"]}'
          ))
      );
    }
    String token = json["token"];

    if (wait) await MarksRegistro.loadMarks(token, username);
    else MarksRegistro.loadMarks(token, username);
    return token;
  }

  @override
  LoginRegistroState createState() {
    return LoginRegistroState();
  }
}

class LoginRegistroState extends State<LoginRegistro> {
  final TextEditingController _unameController = TextEditingController();
  final TextEditingController _pwordController = TextEditingController();
  static bool _autoLogin = true;
  static bool logging = false;


  @override
  void initState() {
    _unameController.text = PrefService.get(USERNAME_KEY) ?? '';
    _pwordController.text = PrefService.get(PASSWORD_KEY) ?? '';
    _autoLogin = PrefService.get(AUTO_LOGIN_KEY) ?? true;

    if (_autoLogin){
      if (_unameController.text != '' && _pwordController.text != '' && !logging) {
        logging = true;
        String username = _unameController.text;
        String password = _pwordController.text;
        Future<String> token = LoginRegistro.makeLogin(context, username, password);
        token.then((str) {
          logging = false;
          widget.parent.log(str, username, password);
        });
      }
    }

    super.initState();
  }

  @override
  void dispose() {
    _unameController.dispose();
    _pwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextFormField uname = TextFormField(
      controller: _unameController,
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
      controller: _pwordController,
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
          if (logging) return;
          logging = true;
          String username = _unameController.text;
          String password = _pwordController.text;
          Future<String> token = LoginRegistro.makeLogin(context, username, password, true);
          token.then((str) {
            logging = false;
            widget.parent.log(str, username, password);
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
        Align(
            alignment: Alignment.centerRight,
            child: Row(
                children: [
                  Text('login automatico'),
                  Checkbox(
                      value: _autoLogin,
                      onChanged: (checked) => setState(() {
                        _autoLogin = checked;
                        PrefService.setBool(AUTO_LOGIN_KEY, checked);
                      })
                  )
                ]
            )
        )
      ],
    );
  }

}

