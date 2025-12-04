import 'package:flutter/material.dart';

class InfosScreen extends StatelessWidget {
  final String title = "RLS Infos";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Text("Screen für RLS Infomaterial und Links", style: TextStyle(fontSize: 20),)
      ),
    );
  }
}
