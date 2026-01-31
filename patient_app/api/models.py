from django.db import models
from django.contrib.auth.models import AbstractUser


#Custom User Model für das Abspeichern von Patienten Zugangsdaten
class CustomPatientUser(AbstractUser):
    @property
    def patient_id(self):  #Funktion die die Patienten ID eines Users erstellt (=die ID die für die FHIR Patient Ressource verwendet wird)
        if self.id is None:
            return None
        return f"p{str(self.id).zfill(9)}"  #gibt patient id mit p am anfang zurück, die immer 10 stellen hat (ID Spalte des User models mit Nullen aufgefüllt).zfill(9)}"  ##gibt patient id mit p am anfang zurück, die immer 10 stellen hat (ID Spalte des User models mit Nullen aufgefüllt)