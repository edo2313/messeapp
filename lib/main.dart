import 'package:flutter/material.dart';
import 'package:messeapp/loginRegistro.dart';
import 'package:messeapp/orari.dart';

void main(){
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
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int index = 0;

  Registro _registro;
  Orari _orari;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
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
        return (_registro ??= Registro(this));
      case 2:
        return (_orari ??= Orari());
      default:
        return Center(child: Text("PAGINA"),);
    }
  }

}
