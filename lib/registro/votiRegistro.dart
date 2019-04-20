import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:messeapp/registro/registro.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MarksRegistro extends StatefulWidget {
  final String token;
  final String username;

  MarksRegistro (this.token, this.username);

  Future<Set<Subject>> loadMarks () async {
    Map head = <String, String>{
      "Z-Dev-Apikey": API_KEY,
      "Content-Type": "application/json",
      "User-Agent": "CVVS/std/1.7.9 Android/6.0)",
      "Z-Auth-Token": token
    };

    // TODO: gestire le eccezioni
    http.Response r = await http.get('https://web.spaggiari.eu/rest/v1/students/${username.substring(1, username.length-1)}/grades2', headers: head);
    print(r.body);
    List json = jsonDecode(r.body)['grades'];
    Set<Subject> subjects = Set();
    Subject last;
    for (Map mark in json){
      if (last == null || mark['subjectCode'] != last)
        last = Subject(mark['subjectCode'], mark['subjectDesc']);
        if (!subjects.add(last))
          for (Subject s in subjects)
            if (s == mark['subjectCode']){
              last = s;
              break;
            }
      last.addMark(Mark(mark['decimalValue']?.toDouble(), mark['displayValue'], mark['notesForFamily'], mark['evtDate']));
    }
    subjects.forEach((s) => s.sort());
    return subjects;
  }

  @override
  MarksRegistroState createState() => MarksRegistroState();

}

class MarksRegistroState extends State<MarksRegistro> {
  static bool loaded = false;
  static List<Subject> subjects;

  @override
  void initState() {
    if (!loaded)
      widget.loadMarks().then((set) {
        if (set == null) return;
        setState(() {
          subjects = set.toList();
          loaded = true;
        });
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) return Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
            child: ExpansionPanelList(
              expansionCallback: (i, exp) => setState(() => subjects[i].switchExpanded()),  // FIXME: non è fluido
              children: subjects.map((s) => s.getExpansionPanel()).toList(),
            )
        )
    );
  }
}


class Subject {
  String subjectCode;
  String subjectName;
  List<Mark> marks = List<Mark>();
  bool _expanded = false;

  Subject (this.subjectCode, this.subjectName);

  void switchExpanded () => _expanded = !_expanded;

  void addMark (Mark mark) {
    marks.add(mark);
  }

  void sort () => marks.sort((m1, m2) => -m1.compareTo(m2));

  ExpansionPanel getExpansionPanel (){
    return ExpansionPanel (
        body: Padding(padding: EdgeInsets.all(10), child: Column(children: marks.expand((m) => [m, Divider()]).toList())),
        isExpanded: _expanded,
        headerBuilder: (context, exp) {
          return ListTile(
              title: Text(subjectName),
              leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text(
                    '10', // TODO: mettere la media
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  )
              )
          );
        }
    );
  }

  @override
  bool operator == (other) {
    if (other is Subject) return subjectCode == other.subjectCode;
    if (other is String) return subjectCode == other;
    return false;
  }

  @override
  int get hashCode {
    return subjectCode.hashCode;
  }

  @override
  String toString() => subjectName;


}

class Mark extends ListTile with Comparable<Mark>{
  final double decimalValue;
  final String displayValue;
  final String info;
  final DateTime date;

  Mark (this.decimalValue, this.displayValue, this.info, String date) :
        date = DateTime.parse(date),
        super (
          title: Text(date.replaceAll('-', '/')), // TODO: invertire la data
          subtitle: Text(info),
          trailing: CircleAvatar(
            backgroundColor: Colors.green,  // TODO: cambiare il colore in base al voto
            child: Text(
              displayValue,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )
          )
        );

  @override
  int compareTo(Mark other) => date.compareTo(other.date);



}