import 'package:flutter/material.dart';


class EinstellungenScreen extends StatelessWidget {
  final String title = "Einstellungen";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Text("Screen für die Einstellungen", style: TextStyle(fontSize: 20),)
      ),
    );
  }
}
