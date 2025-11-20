import 'package:flutter/material.dart';

class FragebogenScreen extends StatelessWidget {
  final String title = "Fragebogen";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Text("Screen für die Fragebögen", style: TextStyle(fontSize: 20),)
      ),
    );
  }
}
