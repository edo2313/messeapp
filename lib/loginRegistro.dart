import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import 'package:messeapp/main.dart';

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
  bool logged = false;
  String token;
  TabController _controller;
  String username;

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
      this.token = token;
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

class LoginRegistro extends StatelessWidget{
  final RegistroState parent;

  LoginRegistro (this.parent);

  /// funzione per prelevare il 'token' da utilizzare per mantenere la sessione
  /// controllo di username e password
  Future<String> makeLogin (BuildContext context, String username, String password) async {
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
            //action: SnackBarAction(label: "RIPROVA", onPressed: () {}),
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
    
    parent.username = username;
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
          Future<String> token = makeLogin(context, unameController.text, pwordController.text);
          token.then((str) => parent.log(str));
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

class MarksRegistro extends StatefulWidget {
  final String token;
  final String username;

  MarksRegistro (this.token, this.username);
  
  Future<String> loadMarks () async {
    Map head = <String, String>{
      "Z-Dev-Apikey": API_KEY,
      "Content-Type": "application/json",
      "User-Agent": "CVVS/std/1.7.9 Android/6.0)",
      "Z-Auth-Token": token
    };

    // TODO: gestire le eccezioni
    http.Response r = await http.get('https://web.spaggiari.eu/rest/v1/students/${username.substring(1, username.length-1)}/grades2', headers: head);
    List json = jsonDecode(r.body)['grades'];
    Set<Subject> subjects = Set();
    for (Map mark in json){
      Subject sbj = Subject(mark['subjectCode'], mark['subjectDesk']);
      if (!subjects.add(sbj)){
        for (Subject s in subjects)
          if (s == mark['subjectCode']){
            sbj = s;
            break;
          }
      }
      sbj.addMark(/* parametro */);
    }

    return null;
  }

  @override
  MarksRegistroState createState() => MarksRegistroState();

}

class MarksRegistroState extends State<MarksRegistro> {
  bool loaded = false;

  @override
  void initState() {
    widget.loadMarks();
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("VOTI"),);
  }

}


class Subject{
  String subjectCode;
  String subjectName;

  Subject (this.subjectCode, this.subjectName);

  void addMark () {
    //TODO
  }

  @override
  bool operator == (other) {
    if (other is Subject) return subjectCode == other.subjectCode;
    if (other is String) return subjectCode == other;
    return false;
  }

}