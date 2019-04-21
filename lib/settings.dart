import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

class Settings extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Impostazioni"),
      ),
      body: PreferencePage([
        PreferenceTitle('General'),
        DropdownPreference(
          'Pagina iniziale',
          'start_page',
          defaultVal: 'Registro',
          values: ['Registro', 'Calendario', 'Orari'],
        ),
        PreferenceTitle('Personalizzazione'),
        SwitchPreference(
          'Tema scuro',
          'darkmode',
          defaultVal: false,
          onChange: () {DynamicTheme.of(context).setBrightness(PrefService.getBool('darkmode') ? Brightness.dark : Brightness.light);},
        ),
    ]),
    );
  }
}