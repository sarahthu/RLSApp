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




Änderungen 01.12.25, von Sarah:

Ordner "mockup_patient" und "mockup_arzt" erstellt + darin den Code für die von Leila erstellten Mockup Apps abgelegt



Änderungen 02.12.25, von Sarah:
Zusätzlich zum "Info"-Screen ein Screen für häufig gestellte Fragen hinzugefügt:
Datei faq_screen.dart mit "FAQScreen" angelegt + Button auf der Homeseite mit dem man auf das Screen kommt


Änderungen 03.12.25, von Sarah:
Navigationbar eingefügt, mit tabs "Home", "Kalender" und "Einstellungen".
Dafür neue Datei "navbar_layout" angelegt, die die Logik zum Wechseln der Tabs enthält.

Knopf "Einstellungen" vom Home Screen entfernt (zu den Einstellungen kommt man ja jetzt über die Navigatiobar)

Icons abgeändert, sodass sie besser zu denen in Leilas Mockup testen 


Änderungen 03.12.25, von Sarah:
Package "table_calendar: ^3.2.0" zu pubspec.yaml hinzugefügt.
Kalender in kalender_screen eingefügt.
Wenn ein Tag ausgwählt wird wird der Benutzer auf das Screen "KalenderAuswahlScreen" weitergeleitet.


Änderungen 06.12.25, von Sarah:
Neues Verzeichnis "fragebogen_definition" angelegt, in dem Codes für das Einspeichern der Fragebögen auf dem FHIR Server abgelegt sind.


Änderungen 10.12.25, von Sarah:
Schnittstelle mit unserem Firely Server hinzugefügt -> Fragebögen werden vom Server geholt, Antworten werden im Server abgespeichert

In views.py zu Django API Views Decorator hinzugefügt. Nicht verwendete Codeabschnitte auskommentiert. API views umbenannt in get_questionnaire und post_response. Bei allen http requests verify=False gesetzt (da wir ein selbst signiertes SSL Zertifikat verwenden und Django das sonst nicht akzeptiert)

In urls.py bei Django questionnaire API einen Path Converter "id" hinzugefügt, sodass man über die gleiche API verschiedene Fragebögen abrufen kann (je nachdem welche id man dazuschreibt) 

FragebogenScreen der flutterapp so abgeändert dass es auf 2 Seiten weiterleitet, IRLSSScreen (das den IRLSS Fragebogen anzeigt) und RLSQOLScreen (das den RLS Quality of Life Fragebogen anzeigt)

Bei IRLSSScreen und RLSQOLScreen beim "Antwort Senden" Knopf Navigator.pop hinzugefügt -> bringt Benutzer nach Absenden des Fragebogens auf das FragebogenScreen zurück.
Format der an Django gesendeten Antworten so abgeändert, dass sie als QuestionnaireResponse Ressource gespeichert werden können


Änderungen 17.12.25, von Sarah:

Pias Arzt App hinzugefügt.

Fragebögen neu eingespeichert, diesmal sodass bei jeder Antwortmöglichkeit der "Wert" der Antwortmöglichkeit für den Score dranhängt

in views.py:
- GET View "getresponse" erstellt, die für einen bestimmten Tag alle ausgefüllten Fragebögen sucht und eine JSON mit Fragentexten, Antworten, Score und weiteren Infos ans Frontend zurückgibt

in ulrs.py:
- Url für die getresponse-View hinzugefügt, mit Path Converter <str:date>

Bei den Flutter Screens zum Fragebogen-Ausfüllen:
- AlertDialog hinzugefügt, der dem Nutzer nach dem Absenden der Antworten den erzielten Score zeigt

Flutter Kalender Screen:
- Sprache des Kalenders auf Deutsch eingestellt
- Wenn man Tag anklickt öffnet sich Liste mit allen aufgefüllten Fragebögen
- Wenn man Fragebögen aus der Liste anklickt sieht man Details zum jeweiligen Fragebogen (um welche Uhrzeit ausgefüllt + welche Antworten hat man gegeben?)

Flutter Infos Screen:
- für Farbverlauf bei dem obersten Link Farben aus dem App-Farbeschema verwendet

Flutter Erinnerungn Screen:
- Sprache von DatePicker und TimePicker auf Deutsch umgestellt
