import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:messeapp/registro/registro.dart';
import 'package:preferences/preferences.dart';
import 'package:messeapp/globals.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String DATA_KEY = 'MARKS_DATA';

class MarksRegistro extends StatefulWidget {

  static Future<List<Period>> loadMarks (String token, String username) async {
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
    Map<int, Period> periods = Map<int, Period>();
    Subject last;
    for (Map mark in json){
      int periodCode = mark['periodPos'];
      String subjectCode = mark['subjectCode']+periodCode.toString();
      Period p = (periods[periodCode] ??= Period(mark['periodDesc']));
      if (last == null || subjectCode != last.subjectCode)
        last = Subject(subjectCode, mark['subjectDesc']);
        if (!p.subjects.add(last))
          for (Subject s in p.subjects)
            if (s == subjectCode){
              last = s;
              break;
            }
      last.addMark(Mark(mark['decimalValue']?.toDouble(), mark['displayValue'], mark['notesForFamily'], mark['evtDate']));
    }
    for (Period p in periods.values) p.subjects.forEach((s) => s.sort());
    // FIXME: mancano delle materie!

    String encodedJson = jsonEncode(periods.values.toList(),
        toEncodable: (obj) {
          if (obj is Period)
            return {
              'period': obj.label,
              'subjects': obj.subjects.toList()
            };
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

    return periods.values.toList();
  }
  static Future<List<Period>> loadMarksFromDb () async {
    List rawPeriods = jsonDecode(PrefService.getString(DATA_KEY)??'[]');
    List<Period> periods = List<Period>();
    rawPeriods.forEach((p) => periods.add(Period.fromMap(p)));
    return periods;
  }

  @override
  MarksRegistroState createState() => MarksRegistroState();

}

class MarksRegistroState extends State<MarksRegistro> {
  static bool loaded = false;
  static List<Period> periods;
  static int periodIndex = 0;
  static List<List<ExpansionPanel>> expPaneLists = [];

  @override
  void initState() {
    if (!loaded)
      MarksRegistro.loadMarksFromDb().then((list) {
        if (list == null) return;
        setState(() {
          periods = list;
          for (Period p in periods) expPaneLists.add(p.subjects.map((s) => s.getExpansionPanel()).toList());
          loaded = true;
        });
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) return Center(child: CircularProgressIndicator());
    List<Expanded> periodsViews = [];
    for (int i=0; i<periods.length; i++){
      periodsViews.add(
          Expanded(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: MaterialButton(  // TODO: modificare lo stile
                    disabledTextColor: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                    textColor: Theme.of(context).brightness == Brightness.light
                        ? Colors.black38
                        : Colors.white30,
                    color: Glob.primarySwatch[900],
                    onPressed: i == periodIndex
                        ? null  // per disattivarlo
                        : () => setState(() {periodIndex = i;}),  // TODO: animazione?
                    child: Text(periods[i].label.toUpperCase()),
                    shape: RoundedRectangleBorder(
                        side: BorderSide(), 
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                  )
              )
          )
      );
    }

    return Column(
        children: <Widget>[
          periodsViews.length>1 ? Row(children: periodsViews) : Container(),  // TODO: quando c'è solo il trimestre, lasciamo un pulsante o eliminiamo del tutto?
          Expanded(
              child: SingleChildScrollView(
                  child: Container(
                      padding: EdgeInsets.all(10),
                      child: ExpansionPanelList(
                        expansionCallback: (i, exp) => setState(() => expPaneLists[periodIndex][i] = (periods[periodIndex].subjects.elementAt(i)..switchExpanded()).getExpansionPanel()),
                        children: expPaneLists[periodIndex],
                      )
                  )
              )
          )
        ],
      );
  }
}

class Period {
  String label;
  final Set<Subject> subjects = Set<Subject>();

  Period (this.label);
  Period.fromMap (Map map) {
    this.label = map['period'];
    map['subjects'].forEach((sbj) => subjects.add(Subject.fromMap(sbj)));
  }
}

class Subject {
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
          title: Text(date.replaceAll('-', '/')), // TODO: invertire la data
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
            backgroundColor: Colors.green,  // TODO: cambiare il colore in base al voto
            child: Text(
              map['displayValue'],
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )
        )
      );

  @override
  int compareTo(Mark other) => date.compareTo(other.date);

}