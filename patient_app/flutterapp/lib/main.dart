import 'package:flutter/material.dart';
import 'package:flutterapp/screens/login_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));  //initializeDateFormatting  wird benötigt um bei table_calendar die Sprache umzustellen
}

class MyApp extends StatelessWidget {  //Der Code in MyApp richtet die gesamte App ein
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        //Einstellungen um Sprache von DatePicker zu ändern:
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en'),
          Locale('de'),  
        ],
        // Sonstige App Einstellungen:
        debugShowCheckedModeBanner: false, //macht das debug Banner oben rechts weg
        title: 'Patient App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        ),
        home: LoginScreen(),
    );
  }
}
