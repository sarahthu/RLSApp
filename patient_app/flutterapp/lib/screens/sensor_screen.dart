import 'package:flutter/material.dart';

class SensorScreen extends StatelessWidget {
  final String title = "Sensordaten";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Text("Screen für die Sensor-Messwerte", style: TextStyle(fontSize: 20),)
      ),
    );
  }
}
