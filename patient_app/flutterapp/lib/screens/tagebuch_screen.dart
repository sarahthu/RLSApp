import 'package:flutter/material.dart';

class TagebuchScreen extends StatelessWidget {
  final String title = "Tagebuch";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Text("Screen für das Tagebuch", style: TextStyle(fontSize: 20),)
      ),
    );
  }
}
