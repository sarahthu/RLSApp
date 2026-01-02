# RLSApp
Änderungen 17.11.25, von Sarah:

Ordner-Grundstruktur erstellt
- Django Projekt "patient_app" erstellt, mit Django App "api" und Flutter App "flutterapp"
- Django Projekt "arzt_app" erstellt, bisher ohne Apps drin

requirements.txt erstellt, das folgende Packete enthält:
- Django
- djangorestframework
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



Änderungen 02.01.2026, von Sarah:

Gemeinsame sqlite3 Datenbank für arzt_app und patient_app im Verzeichnis RLSApp angelegt + Position der Datenbank in den Settings der beiden Apps eingetragen

bei patient_app/api:
Login-APIs implementiert, mithilfe des djangorestframework-simplejwt Pakets:

- in models.py ein Custom UserModel für Patienten angelegt, sodass man von jedem Patient zusätzlich zu name und passwort auch eine patient_id ausgeben lassen kann, die immer 10 stellig ist

- in serializers.py und views.py Serializers und Views für Login und Registrierung angelegt, Code fast vollständig von "https://medium.com/@onurmaciit/mastering-jwt-authentication-in-django-rest-framework-best-practices-and-techniques-d47f906f530a" übernommen

- in urls.py Routen für Registrierung und Login angelegt

- in views.py View post_patient angelegt, die bei der Registrierung von neuen Patienten mit den eingegebenen Daten Vorname, Nachname und Geburtsdatum eine FHIR Patient Ressource erstellt

- in views.py außer post_patient (weil der User direkt nach dem Registrieren noch kein Token hat) bei allen views @permission_classes([IsAuthenticated]) hinzugefügt, sodass sie  nur verwendet werden wenn User authentifiziert ist bzw. ein gültiges Token besitzt

- in views.py API zum speichern von Fragebögen Antworten so umgeändert, dass bei jeder QuestionnaireResponse ein Verweis auf der Patienten drin ist der den Fragebogen ausgefüllt hat



Bei flutterapp:

- dio http client erstellt (in dio_setup.dart), der bei jeder request das AcessToken des Benutzers als header mitschickt. Alle http requests die wir zuvor mit dem http paket gemacht haben auf Dio umgeändert

- service jwt.service erstellt, der Methoden rund um Token Management und User Authentifizierung enthält: saveToken, getToken, deleteToken, login, signup, logout. Tokens werden in Flutter SecureStorage gespeichert.
Code dafür zu großen Teilen aus "https://medium.com/@areesh-ali/building-a-secure-flutter-app-with-jwt-and-apis-e22ade2b2d5f" übernommen

- in Login Screen login Funktionalität hinzugefügt

- RegistrierungsScreen für die Registrierung von neuen Patienten angelegt. Dort eingegebene Zugangsdaten werden vom Backend in der sqlite Datenbank gespeichert, weitere Informationen zu dem Patient auf dem FHIR Server

- ResponseScreen so verändert, dass die Zeit wann der Fragebogen ausgefüllt wurde in der Lokalen Zeitzone angegeben wird, nicht in UTC

- in TagebuchScreen ListTiles hinzugefügt, über die man auf die Fragen zu den verschiedenen Kategorien gelangen kann

- TagebuchAuswahlScreen hinzugefügt, dass für jede ausgewählte Kategorie die 5 Fragen sowie zwei Textfelder für private und öffentliche Tagebucheinträge anzeigt. Methoden zur Speicherung der Antworten sind von den Fragebögen Screens übernommen und funktionieren bisher noch nicht ganz für die Speicherung von Tagebucheinträgen --> Richtige Speicherung von Tagebuch-Antworten muss noch implementiert werden


Code zur Speicherung der Tagebuchfragen für Kategorie "Achtsamkeit" erstellt und die Fragen auf dem FHIR Server abgespeichert.
Bei allen abgespeicherten Fragebögen als purpose "fragebogen" oder "tagebuch" hinzugefügt, um zwischen anerkannten medizinischen Fragebögen und unseren Tagebuch-Fragen unterscheiden zu können






