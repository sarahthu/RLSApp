import 'package:flutter/material.dart';

class KalenderScreen extends StatelessWidget {
  final String title = "Kalender";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Text("Screen für den Kalender", style: TextStyle(fontSize: 20),)
      ),
    );
  }
}
