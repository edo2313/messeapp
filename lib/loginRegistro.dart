import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;

class LoginRegistro extends StatefulWidget{


  static Future<String> makeLogin (BuildContext context, String username, String password) async {
    Map<String, String> data = Map();
    data["cid"]="";
    data.putIfAbsent("uid", () => username);
    data.putIfAbsent("pwd", () => password);
    data["pin"]="";
    data["target"]="";
    int status=1;
    try{
      await http.get('https://web.spaggiari.eu');
    }
    catch(SocketException){
      status = 0;
    }
    if (status==0){
      Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("Controlla la connessione ad internet"),
            action: SnackBarAction(label: "RIPROVA", onPressed: () => makeLogin(context, username, password),),
          )
      );
      return null;
    }
    http.Response r = await http.post('https://web.spaggiari.eu/auth-p7/app/default/AuthApi4.php?a=aLoginPwd', body: data);
    var json = jsonDecode(r.body);
    assert (json is Map);
    bool logged = json.values.elementAt(1).values.elementAt(0).values.elementAt(1);
    if (!logged) {
      Scaffold.of(context).showSnackBar(
        SnackBar(content: Text(
            json.values.elementAt(1).values.elementAt(0).values.elementAt(4).toString()
        ))
      );
      return null ;
    }
    else{
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(
              'Benvenuto ${json.values.elementAt(1).values.elementAt(0).values.elementAt(5).values.elementAt(3).toString()} ${json.values.elementAt(1).values.elementAt(0).values.elementAt(5).values.elementAt(2).toString()}'
          ))
      );
    }

    /*String setCookies = r.headers.values.elementAt(2);
    print (setCookies);
    set_cookies = set_cookies.substring(0, 42);*/
    String setCookies = 'webrole=gen; webidentity=$username; ${r.headers.values.elementAt(2).substring(0, 42)}; weblogin=$username; LAST_REQUESTED_TARGET=cvv'; //TODO: Non funziona, bisogna capire come dargli in pasto la session
    print (setCookies);


    //test: not working
    r = await http.get('', headers: {'Cookie': setCookies});
    dom.Document doc = parse(r.body);
    print (doc.children.elementAt(0).children.elementAt(1).children.elementAt(0).innerHtml);

    return setCookies;
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
          LoginRegistro.makeLogin(
              context, unameController.text, pwordController.text);
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