import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import 'package:messeapp/registro/registro.dart';
import 'package:messeapp/globals.dart';
import 'package:http/http.dart' as http;
import 'package:android_intent/android_intent.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission/permission.dart';


class NoticeBoardRegistro extends StatefulWidget {

  static Future<List> loadNoticeBoard (String token, String username) async {
    Map head = <String, String>{
      'Z-Dev-Apikey': API_KEY,
      'Content-Type': 'application/json',
      'User-Agent': 'CVVS/std/1.7.9 Android/6.0)',
      'Z-Auth-Token': token,
      'Z-If-None-Match': PrefService.getString('notice_board_etag')
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
      'valid': m['cntValidInRange'] && m['cntStatus']=='active',
      'contentTitle': m['cntTitle'],
      'contentText': null,              // scaricabile dal link 'https://web.spaggiari.eu/rest/v1/students/$username/noticeboard/read/$eventCode/$pubId/101'
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

  static Future<bool> downloadPdf (String eventCode, int pubId, int index, String filename) async {
    print (await Permission.requestSinglePermission(PermissionName.Storage));
    if (await Permission.requestSinglePermission(PermissionName.Storage) != PermissionStatus.allow) return false;

    // TODO: notificare eventuali errori e la percentuale di caricamento

    String username = PrefService.getString('CVVS_UNAME');
    if (username == null) return null;
    username = username.substring(1, username.length-1);
    http.Response r = await http.get(
        'https://web.spaggiari.eu/rest/v1/students/$username/noticeboard/attach/$eventCode/$pubId/${index+1}',
        headers: {
          'Z-Dev-Apikey': API_KEY,
          'Content-Type': 'application/json',
          'User-Agent': 'CVVS/std/1.7.9 Android/6.0)',
          'Z-Auth-Token': Glob.token,
        }
    );
    if (r.statusCode != 200) return false;
    File f = File((await getExternalStorageDirectory()).path+'/messeapp/notices/$filename');
    f.createSync(recursive: true);
    f.writeAsBytesSync(r.bodyBytes, flush: true);
    print (f.uri.toString());
    await AndroidIntent(action: 'action_view', data: f.uri.toString()).launch();
    return true;
  }

  static Future<String> loadSingle (String eventCode, int pubId) async {
    String username = PrefService.getString('CVVS_UNAME');
    if (username == null) return null;
    username = username.substring(1, username.length-1);
    http.Response r = await http.post(
        'https://web.spaggiari.eu/rest/v1/students/$username/noticeboard/read/$eventCode/$pubId/101',
      headers: {
        'Z-Dev-Apikey': API_KEY,
        'Content-Type': 'application/json',
        'User-Agent': 'CVVS/std/1.7.9 Android/6.0)',
        'Z-Auth-Token': Glob.token,
        //'Z-If-None-Match': PrefService.getString('notice_board_etag')
      }
    );
    if (r.statusCode != 200) return null;
    return jsonDecode(r.body)['item']['text'].trim();
  }

  @override
  NoticeBoardRegistroState createState() {
    return NoticeBoardRegistroState();
  }
}

class NoticeBoardRegistroState extends State<NoticeBoardRegistro> {
  static List _list;
  static List<ExpansionPanel> _expansionPanelList;
  static bool loading = false;


  @override
  void initState() {
    super.initState();
    if (_list == null)
      setState(() {
        _list = NoticeBoardRegistro.loadNoticeBoardFromDb().where((c) => c['valid']).toList();
        _expansionPanelList = _list.map((m) =>
            ExpansionPanel(
                isExpanded: false,
                headerBuilder: (context, exp) => headerBuilder(m, context, exp),
                body: body(m)
            )
        ).toList();
      });
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(10),
      child: ExpansionPanelList(
        expansionCallback: (i, exp) {
          if (_list[i]['contentText'] == null) {
            loading = true;
            NoticeBoardRegistro.loadSingle(_list[i]['eventCode'], _list[i]['pubId']).then(
                    (str) {
                      loading = false;
                      _list[i]['contentText'] = str;
                      _expansionPanelList[i] = ExpansionPanel(
                          isExpanded: !exp,
                          headerBuilder: (context, exp) => headerBuilder(_list[i], context, exp),
                          body: Padding(
                              padding: EdgeInsets.all(10),
                              child: body(_list[i])
                          )
                      );

                      setState(() {});
                    }
            );
          }


          setState(() => _expansionPanelList[i] = ExpansionPanel(
              isExpanded: !exp,
              headerBuilder: (context, exp) => headerBuilder(_list[i], context, exp),
              body: body(_list[i])
          ));

        },
        children: _expansionPanelList,
      ),
    );
  }

  Widget headerBuilder (Map m, BuildContext context, bool exp) =>
    ListTile(
      contentPadding: EdgeInsets.all(10),
      title: Text(
        m['contentTitle'],
        maxLines: exp ? null : 2,
        overflow: exp ? null : TextOverflow.ellipsis,
        style: TextStyle(fontWeight: m['read'] ? FontWeight.normal : FontWeight.bold)
      ),
      leading: m['hasAttach']
          ? GestureDetector(
              child: Icon(Icons.file_download),
              onTap: () {
                for (int i=0; i<m['attachments'].length; i++) NoticeBoardRegistro.downloadPdf(m['eventCode'], m['pubId'], i, m['attachments'][i]['fileName']);
              },)
          : null,
    );

  Widget body (Map m) {
    if (m['contentText'] != null) return Text(m['contentText']);
    if (loading) return Center(child: CircularProgressIndicator());
    return Text('Impossibile visualizzare il contenuto della comunicazione!');
  }
}

