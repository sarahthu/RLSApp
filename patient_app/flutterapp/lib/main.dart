import 'package:flutter/material.dart';
import 'package:flutterapp/screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {  //Der Code in MyApp richtet die gesamte App ein
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false, //macht das debug Banner oben rechts weg
        title: 'Patient App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: LoginScreen(),
    );
  }
}
