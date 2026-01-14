import 'package:flutter/material.dart';

class EinstellungenScreen extends StatefulWidget {
  const EinstellungenScreen({super.key});

  final String title = "Einstellungen";
  @override
  State<EinstellungenScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<EinstellungenScreen> {

  bool pushNotifications = true;     // Speichert, ob Push-Benachrichtigungen aktiviert sind

  @override
  Widget build(BuildContext context) {      // build-Methode baut die Benutzeroberfläche

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
              leading: const CircleAvatar(child: Text('P')),
              title: const Text('Patient'),
              subtitle: const Text('RLS DiGA Patient'),
              trailing: TextButton(                       // Button zum Bearbeiten des Profils
                onPressed: _openEditProfileDialog,
                child: const Text('Bearbeiten'),
              ),
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

          /// ---------------- Benachrichtigungen ----------------
          const Text(
            'Benachrichtigungen',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Card(                                             // Schalter für Push-Benachrichtigungen
            child: SwitchListTile(
              title: const Text('Push-Benachrichtigungen'),
              subtitle: const Text('Erinnerungen und Updates'),
              value: pushNotifications,
              onChanged: (value) {                 // Aktualisiert den Zustand beim Umschalten
                setState(() {
                  pushNotifications = value;
                });
              },
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
              backgroundColor: Colors.red,
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
        content: const Text('Möchtest du dich wirklich abmelden?'),
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

    ScaffoldMessenger.of(context).showSnackBar(         // Kurze Rückmeldung für den Nutzer
      const SnackBar(content: Text('Du wurdest abgemeldet.')),
    );

    // Ersetze LoginScreen() durch deinen echten Login-Screen!
    Navigator.pushAndRemoveUntil(               //  öffnet den Login-Screen
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
 
  /// ---------------- Dialog: Profil bearbeiten ----------------
  void _openEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profil bearbeiten'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TextField(decoration: InputDecoration(labelText: 'Name')),
            TextField(decoration: InputDecoration(labelText: 'E-Mail')),
            TextField(decoration: InputDecoration(labelText: 'Telefon')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Speichern'),
          ),
        ],
      ),
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

/// Platzhalter: Ersetze das durch deinen echten Login-Screen
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Login Screen (Platzhalter)')),
    );
  }
}
