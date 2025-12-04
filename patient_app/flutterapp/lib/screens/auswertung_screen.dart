import 'package:flutter/material.dart';


class AuswertungScreen extends StatelessWidget {
  final String title = "Auswertungen";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Text("Screen für die Auswertungen", style: TextStyle(fontSize: 20),)
      ),
    );
  }
}
