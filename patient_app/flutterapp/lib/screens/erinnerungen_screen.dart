import 'package:flutter/material.dart';


class ErinnerungenScreen extends StatelessWidget {
  final String title = "Erinnerungen";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Text("Screen für die Erinnerungen", style: TextStyle(fontSize: 20),)
      ),
    );
  }
}