import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import 'package:messeapp/registro/registro.dart';
import 'package:http/http.dart' as http;

class NoticeBoardRegistro extends StatelessWidget {

  static Future<void> loadNoticeBoard (String token, String username) async {
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
  }


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('BACHECA'),
    );
  }
}