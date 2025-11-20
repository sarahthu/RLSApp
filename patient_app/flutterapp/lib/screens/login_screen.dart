import 'package:flutter/material.dart';
import 'package:flutterapp/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  final String title = "Login Screen";

  @override
  State<LoginScreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  final usernameController = TextEditingController(); //Erstellt einen Controller um Eingaben im Username Textfeld zu speichern
  final passwordController = TextEditingController(); //Erstellt einen Controller um Eingaben im Passwort Textfeld zu speichern

  // dispose Methode (wird auf Flutter Webseite empfohlen: https://docs.flutter.dev/cookbook/forms/text-field-changes)
  // entfernt glaube ich die Controller wenn sie nicht mehr gebraucht werden (??)
    @override
  void dispose() {  
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,   
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Bitte Benutzername und Passwort eingeben:", style: TextStyle(fontSize: 20),),  //Text
            SizedBox(height: 20,),
            TextField(     //Eingabefeld für den Benutzernamen
                controller: usernameController,  //Eingaben werden über den usernameController überwacht
                decoration: InputDecoration(
                  labelText: 'Benutzername',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(     //Eingabefeld für das Passwort
                controller: passwordController,   //Eingaben werden über den passwordController überwacht
                decoration: InputDecoration(
                  labelText: 'Passwort',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            SizedBox(height: 20,),
            ElevatedButton.icon(    //"Login" Knopf
              icon: Icon(Icons.person),
              onPressed: () {    //Wenn der "Login" Knopf gedrückt wird wird die login Methode aufgerufen
                login();
              },
              label: const Text('Login', style: TextStyle(fontSize: 25),),
            ),
          ],
        )
      ),
    );
  }

  void login() {
      final username = usernameController.text.trim();  //speichert Eingabe in dem Username Feld unter variable "username"
      final password = passwordController.text.trim();  //speichert Eingabe in dem Passwort Feld unter Variable "password"

      //Leitet Benutzer auf das Homescreen weiter:
      //(hier kommt dann irgendwann eine richtige Login Funktion hin wo username und Passwort tatsachlich geprüft werden)
      //Navigator.pushReplacement verhindert dass man auf die Login Seite zurückgehen kann 
      //(im Gegensatz zu Navigator.push was im Homescreen verwendet wird und oben rechts immer den Zurückknopf hinmacht)
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                  return HomeScreen();
                }));
  }

}
