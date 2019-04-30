import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import 'package:messeapp/registro/registro.dart';
import 'package:http/http.dart' as http;

class NoticeBoardRegistro extends StatefulWidget {

  static Future<List> loadNoticeBoard (String token, String username) async {
    Map head = <String, String>{
      'Z-Dev-Apikey': API_KEY,
      'Content-Type': 'application/json',
      'User-Agent': 'CVVS/std/1.7.9 Android/6.0)',
      'Z-Auth-Token': token,
      //'Z-If-None-Match': PrefService.getString('notice_board_etag')
    };

    // TODO: gestire le eccezioni
    http.Response r = await http.get('https://web.spaggiari.eu/rest/v1/students/${username.substring(1, username.length-1)}/noticeboard', headers: head);
    if (r.statusCode != 200) return null;
    PrefService.setString('notice_board_etag', r.headers['etag']);
    print (r.body);
    List json = jsonDecode(r.body)['items'];

    List list = json.map((m) => {
      'pubId': m['pubId'],
      'pubDate': m['pubDT'],
      'read': m['readStatus'],
      'eventCode': m['evtCode'],
      'valid': m['cntValidInRange'],
      'contentTitle': m['cntTitle'],
      'hasContentText': m['cntStatus']=='active',
      'contentText': null,              // scaricabile dal link 'https://web.spaggiari.eu/rest/v1/students/$username/noticeboard/attach/$eventCode/$pubId/101'
      'hasAttach': m['cntHasAttach'],
      'attachments': m['attachments']   // scaricabili dal link 'https://web.spaggiari.eu/rest/v1/students/$username/noticeboard/attach/$eventCode/$pubId/${index+1}'
    }).toList();

    PrefService.setString('notice_board_data', jsonEncode(list));
    /*
    {
      pubId                       *int*
      pubDT                       *String*    date second
      readStatus                  *bool*
      evtCode                     *String*    CF?
      cntId                       *int*
      cntValidFrom                *String*    date day
      cntValidTo                  *String*    date day
      cntValidInRange             *bool*
      cntStatus                   *String*    "active"|"deleted"
      cntTitle                    *String*
      cntCategory                 *String*    "Scuola/famiglia"|"Circolare"
      cntHasChanged               *bool*
      cntHasAttach                *bool*
      needJoin                    *bool*
      needReply                   *bool*
      needFile                    *bool*
      attachments                 *List*
    }
    */
    return list;
  }
  static List loadNoticeBoardFromDb () {
    String data = PrefService.getString('notice_board_data');
    if (data == null) return null;
    return jsonDecode(data);
  }

  @override
  NoticeBoardRegistroState createState() {
    return NoticeBoardRegistroState();
  }
}

class NoticeBoardRegistroState extends State<NoticeBoardRegistro> {
  static List _list;
  static int _expanded;


  @override
  void initState() {
    super.initState();
    if (_list == null)
      setState(() => _list = NoticeBoardRegistro.loadNoticeBoardFromDb());
  }


  @override
  void dispose() {
    PrefService.setString('notice_board_data', jsonEncode(_list));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_list == null)
      return Center(
        child: Text('NON SONO PRESENTI COMUNICAZIONI'),
      );
    int i = 0;
    List expPanels = _list.map((m) =>
        ExpansionPanel(
            isExpanded: i++ == _expanded,
            headerBuilder: (context, exp) => ListTile(
              title: Text(m['contentTitle'], style: TextStyle(fontWeight: m['read'] ? FontWeight.normal : FontWeight.bold),),
              leading: m['hasAttach'] ? Icon(Icons.file_download) : null,
            ),
            body: Text('qui ci va il testo della comunicazione')
        )
    ).toList();
    return SingleChildScrollView(
      padding: EdgeInsets.all(10),
      child: ExpansionPanelList(
        expansionCallback: (i, exp) => setState(() => _expanded = exp ? null : i),
        children: expPanels,
      ),
    );
  }
}

