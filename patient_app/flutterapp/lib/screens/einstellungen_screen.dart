import 'package:flutter/material.dart';
import 'package:flutterapp/dio_setup.dart';
import 'package:flutterapp/screens/login_screen.dart';
import 'package:flutterapp/services/jwt_service.dart';


class EinstellungenScreen extends StatefulWidget {
  const EinstellungenScreen({super.key});

  final String title = "Einstellungen";
  @override
  State<EinstellungenScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<EinstellungenScreen> {
  final jwtService = JwtService(); //erstellt Jwtservice
  bool pushNotifications = true;     // Speichert, ob Push-Benachrichtigungen aktiviert sind
  bool loading = true; //True solange Daten geladen werden
  Map<String, dynamic>? profil; // Speichert Profildaten
  String? error; //Fehlertext, falls etwas schiefgeht


  @override
  void initState() {
    super.initState();
    loadPorfile();  //Beim Start Profildaten laden
  }

  //---------------Fragebogen vom Django Server laden--------------------------------------------------
  Future<void> loadPorfile() async {
    try {
      final resp = await dio.get("/rls/profil/");

      if (resp.statusCode == 200) {
        //JSON erfolgreich erhalten → speichern
        setState(() {
          profil = resp.data;
          loading = false;
        });
      } else {
        setState(() {
          error = 'Fehler: ${resp.statusCode}';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Fehler: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {      // build-Methode baut die Benutzeroberfläche

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(child: Text(error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary, // die vorgegebene Farbe wird benutzt 
        title: Text(widget.title),
      ),
      body: ListView(                       // Liste für alle Einstellungen
        padding: const EdgeInsets.all(16),
        children: [
          /// ---------------- Profil ----------------
          Card(
            child: ListTile(                // Profil-Icon
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: const Text('Profil', style: TextStyle(fontWeight: FontWeight.bold),),
              // subtitle: const Text('Patienteninformationen:'),
              subtitle: Text("Vorname: ${profil?["vorname"]}\nNachname: ${profil?["nachname"]}\nGebusrtsdatum: ${profil?["geburtsdatum"]}",),
            ),
          ),

          const SizedBox(height: 20),

          /// ---------------- Konto & Sicherheit ----------------
          const Text(
            'Konto & Sicherheit',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Card(                                          // Eintrag zum Passwortänderung
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Passwort ändern'),
              onTap: _openChangePasswordDialog,
            ),
          ),

          const SizedBox(height: 20),

          /// ---------------- Rechtliches ----------------
          const Text(
            'Rechtliches',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Datenschutzerklärung'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 0),
                ListTile(
                  title: const Text('Nutzungsbedingungen'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 0),
                ListTile(
                  title: const Text('Impressum'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          /// ---------------- Abmelden ----------------
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: _logout,                     // Beim Klick wird die Logout-Funktion aufgerufen
            icon: const Icon(Icons.logout),
            label: const Text('Abmelden'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(        // Dialog zur Bestätigung
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abmelden'),
        content: const Text('Möchten Sie sich wirklich abmelden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Abmelden'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    jwtService.logout; //Meldet den User ab indem AcessToken aus dem Speicher gelöscht wird

    ScaffoldMessenger.of(context).showSnackBar(         // Kurze Rückmeldung für den Nutzer
      const SnackBar(content: Text('Sie wurden abgemeldet.')),
    );

    Navigator.pushAndRemoveUntil(               //  öffnet den Login-Screen
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }
 

  /// ---------------- Dialog: Passwort ändern ----------------
  void _openChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Passwort ändern'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Aktuelles Passwort'),
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Neues Passwort'),
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Passwort bestätigen'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'), 
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Passwort ändern'),
          ),
        ],
      ),
    );
  }
}
