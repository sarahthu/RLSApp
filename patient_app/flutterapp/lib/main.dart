import 'package:flutter/material.dart';

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
        home: const HomePage(title: 'Homepage'),
    );
  }
}


//--------------------- Homepage --------------------------------------------------

class HomePage extends StatelessWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,   //Buttons werden mittig in der Column angezeigt
          children: [
            ElevatedButton.icon(    //Knopf zur ersten Seite
              icon: Icon(Icons.question_mark),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const FragebogenPage(title: 'FragebogenPage');
                }));
              },
              label: const Text('Fragebögen', style: TextStyle(fontSize: 25),),
            ),
            SizedBox(height: 10,),   //Abstand zwischen Knöpfen
            ElevatedButton.icon(   //Knopf zur zweiten Seite
              icon: Icon(Icons.mode_edit),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const TagebuchPage(title: 'TagebuchPage');
                }));
              },
              label: const Text('Tagebuch', style: TextStyle(fontSize: 25),),
            ),
            SizedBox(height: 10,),   //Abstand zwischen Knöpfen
            ElevatedButton.icon(    //Knopf zur dritten Seite
              icon: Icon(Icons.abc),   
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const ThirdPage(title: 'ThirdPage');
                }));
              },
              label: const Text('Seite 3', style: TextStyle(fontSize: 25),),
            ),
          ],
        ),
      ),
    );
  }
}


//--------------------- Erste Seite --------------------------------------------------

class FragebogenPage extends StatelessWidget {
  const FragebogenPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Text("Hallo das ist die Page für die Fragebögen", style: TextStyle(fontSize: 20),)
      ),
    );
  }
}


//--------------------- Zweite Seite --------------------------------------------------

class TagebuchPage extends StatelessWidget {
  const TagebuchPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Text("Hallo das ist die Page für das Tagebuch", style: TextStyle(fontSize: 20),)
      ),
    );
  }
}


//--------------------- Dritte Seite --------------------------------------------------

class ThirdPage extends StatelessWidget {
  const ThirdPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Text("Hallo das ist eine Dritte Seite", style: TextStyle(fontSize: 20),)
      ),
    );
  }
}