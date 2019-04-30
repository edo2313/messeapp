// WORK IN PROGRESS

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:messeapp/registro/registro.dart';
import 'package:preferences/preferences.dart';
import 'package:messeapp/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String DATA_KEY = 'LESSONS_DATA';

class LessonsRegistro extends StatefulWidget {

  static Future/*<List<Subject>>*/ loadLessons (String token, String username) async {
    Map head = <String, String>{
      "Z-Dev-Apikey": API_KEY,
      "Content-Type": "application/json",
      "User-Agent": "CVVS/std/1.7.9 Android/6.0)",
      "Z-Auth-Token": token
    };

    int currentYear = DateTime.now().year - (DateTime.now().month >= DateTime.september ? 0 : 1);

    // TODO: gestire le eccezioni
    http.Response r = await http.get(
        'https://web.spaggiari.eu/rest/v1/students/${username.substring(1, username.length-1)}/lessons/${currentYear}0901/${currentYear+1}0630',
        headers: head
    );
    print(r.body);
    List json = jsonDecode(r.body)['lessons'];

    /// ogni elemento nella lista è una mappa, le chiavi sono:
    /// {
    ///   [evtId] : identificatore univoco, possiamo usarlo, come per i voti, per sapere quando ci sono degli aggiornamenti *int*
    ///   [evtDate] : data di pubblicazione *String*
    ///   [evtCode] : ? *String*
    ///   [evtHPos] : indice della lezione all'interno della materia (?) *int*
    ///   [evtDuration] : durata in ore della lezione (?) *int*
    ///   [classDesc] : informazioni sulla classe frequentata dallo studente *String*
    ///   [authorName] : nome del docente *String*
    ///   [subjectId] : identificatore della materia *int*
    ///   [subjectCode] : codice della materia (nome accorciato in modo univoco) *String*
    ///   [subjectDesc] : nome della materia *String*
    ///   [lessonType] : lezione | interrogazione | ecc... *String*
    ///   [lessonArg] : informazioni sulla lezione *String*
    ///}

    // copia-incolla da loginRegistro
    /*Set<Subject> subjects = Set();
    Subject last;
    for (Map mark in json){
      if (last == null || mark['subjectCode'] != last.subjectCode)
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

    String encodedJson = jsonEncode(subjects.toList(),
        toEncodable: (obj) {
          if (obj is Subject)
            return {
              'subjectCode': obj.subjectCode,
              'subjectName': obj.subjectName,
              'marks': obj.marks
            };
          if (obj is Mark)
            return {
              'decimalValue': obj.decimalValue,
              'displayValue': obj.displayValue,
              'info': obj.info,
              'date': '${obj.date.year.toString().padLeft(4,'0')}-${obj.date.month.toString().padLeft(2,'0')}-${obj.date.day.toString().padLeft(2,'0')}'
            };
        }
    );

    print (encodedJson);

    await PrefService.setString(DATA_KEY, encodedJson);

    return subjects.toList();*/
  }
  static Future/*<List<Subject>>*/ loadMarksFromDb () async {
    /*List rawSubjects = jsonDecode(PrefService.getString(DATA_KEY)??'[]');
    List<Subject> subjects = List<Subject>();
    rawSubjects.forEach((sbj) => subjects.add(Subject.fromMap(sbj)));
    return subjects;*/
  }

  @override
  LessonsRegistroState createState() => LessonsRegistroState();

}

class LessonsRegistroState extends State<LessonsRegistro> {
  static bool loaded = false;
  //static List<Subject> subjects;
  static List<ExpansionPanel> expPaneList;

  @override
  void initState() {
    /*if (!loaded)
      LessonsRegistro.loadMarksFromDb().then((list) {
        if (list == null) return;
        setState(() {
          subjects = list;
          expPaneList = subjects.map((s) => s.getExpansionPanel()).toList();
          loaded = true;
        });
      });*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /*if (!loaded) return Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.all(10),
            child: ExpansionPanelList(
              expansionCallback: (i, exp) => setState(() => expPaneList[i] = (subjects[i]..switchExpanded()).getExpansionPanel()),
              children: expPaneList,
            )
        )
    );*/
    return Center(child: Text('LEZIONI'));
  }
}


/*class Subject {
  String subjectCode;
  String subjectName;
  List<Mark> marks = List<Mark>();
  bool _expanded = false;
  double _average;
  Widget body;

  Subject (this.subjectCode, this.subjectName);
  Subject.fromMap (Map map) {
    subjectCode = map['subjectCode'];
    subjectName = map['subjectName'];
    map['marks'].forEach((m) => addMark(Mark.fromMap(m)));
    sort();
  }

  void switchExpanded () => _expanded = !_expanded;

  void addMark (Mark mark) {
    marks.add(mark);
  }

  void sort () {
    double sum = 0;
    int validSize = 0;  // escludiamo i voti blu
    marks.forEach((m) {
      if (m.decimalValue == null) return; // voto blu
      sum += m.decimalValue;
      validSize++;
    });
    if (validSize != 0)   // se ci sono solo voti blu, allora la media è 'null'
      _average = sum/validSize;
    marks.sort((m1, m2) => -m1.compareTo(m2));
    body = Padding(padding: EdgeInsets.all(10), child: Column(children: marks.expand((m) => [m, Divider()]).toList()));
  }

  ExpansionPanel getExpansionPanel (){
    return ExpansionPanel (
        body: body,
        isExpanded: _expanded,
        headerBuilder: (context, exp) {
          return ListTile(
              title: Text(subjectName),
              leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text(
                    _average?.toStringAsFixed(1) ?? '',
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
          title: Text(date.replaceAll('-', '/')),
          subtitle: Text(info),
          trailing: CircleAvatar(
              backgroundColor: decimalValue!=null
                  ? decimalValue<6 ? Colors.red : Colors.green
                  : Colors.blue,
              child: Text(
                displayValue,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )
          )
      );

  Mark.fromMap (Map map) :
        date = DateTime.parse(map['date']),
        decimalValue = map['decimalValue'],
        displayValue = map['displayValue'],
        info = map['info'],
        super (
          title: Text(map['date'].replaceAll('-', '/')),
          subtitle: Text(map['info']),
          trailing: CircleAvatar(
              backgroundColor: Colors.green,
              child: Text(
                map['displayValue'],
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )
          )
      );

  @override
  int compareTo(Mark other) => date.compareTo(other.date);

}*/