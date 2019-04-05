import 'package:flutter/material.dart';
import 'loginRegistro.dart';

void main(){
  // test temporaneo
  LoginRegistro.makeLogin('', '');

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
      body: Center(
        child: Text ("PAGINA")
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.vpn_key), title: Text('REGISTRO')),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), title: Text('AGENDA')),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), title: Text('ORARI')),
        ],
        onTap: (int i) => setState(() => index = i),
      ),
    );
  }
}
