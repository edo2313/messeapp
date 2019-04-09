import 'package:flutter/material.dart';
import 'loginRegistro.dart';
import 'orari.dart';

void main(){
  // test temporaneo
  //LoginRegistro.makeLogin('aaa', 'bbb');
  Orari.loadLinks();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MyHomePage(title: 'MESSEAPP'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title))
      ),
      body: buildBody(context),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.vpn_key), title: Text('REGISTRO')),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), title: Text('AGENDA')),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), title: Text('ORARI')),
          BottomNavigationBarItem(icon: Icon(Icons.settings), title: Text("IMPOSTAZIONI"))
        ],
        onTap: (int i) => setState(() => index = i),
      ),
    );
  }
  Widget buildBody (BuildContext context) {
    switch (index){
      case 0:
        return buildLogin(context);
        default:
        return Center(child: Text("PAGINA"),);
    }
  }
  Widget buildLogin (BuildContext context) {
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
        onPressed: (){LoginRegistro.makeLogin(context, unameController.text, pwordController.text);},
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
