# RLSApp
Änderungen 17.11.25, von Sarah:

Ordner-Grundstruktur erstellt
- Django Projekt "patient_app" erstellt, mit Django App "api" und Flutter App "flutterapp"
- Django Projekt "arzt_app" erstellt, bisher ohne Apps drin

requirements.txt erstellt, das folgende Packete enthält:
- Django
- djanorestframework
- django-cors-headers (braucht man damit Django mit Flutter Frontend funktioniert)
- django-extensions (Django Zusatzfunktionen. show_urls zeigt z.B. alle URLs der Django App an)
- requests (für HTTP Anfragen -> ermöglicht es Ressourcen von FHIR Server anzufragen)
- fhir.resources (für das Erstellen von FHIR Ressourcen)

zum Installieren dieser Pakete müsst ihr folgendes machen:
1. (Im RLSApp Verzeichnis) virtuelle Umgebung erstellen mit Befehl "py -3 -m venv .venv"
2. virutelle Umgebung aktivieren mit Befehl ".venv\scripts\activate"
3. requirements installieren mit "pip install -r requirements.txt"


Flutter App hinzugefügt.
Die App hat eine Hompage auf der man über Buttons zu drei anderen Pages gelangen kann.




Änderungen 20.11.25, von Sarah:

In flutterapp/lib einen neuen Ordner "screens" erstellt
Dort folgende screens angelegt:
- Login
- Home
- Fragebogen
- Tagebuch
- Sensor
- Info
- Auswertung
- Einstellungen

Das Login Screen enthält 2 Textfelder. Die Eingaben in beiden Feldern werden mithilfe von TextEditingControllern in den Variablen "username" und "password" gespeichert.
(die kann man dann später verwenden wenn man eine richtige Login-Funktion implementiert)

Home Screen enthält 6 Elevatedbuttons mit Icons.

Alle anderen Screens zeigen nur eine Zeile Text.


Aus main.dart wurde aller Code für Screens entfernt;
dort wird nun nur noch die App erstellt und das Login Screen als default route eingestellt.