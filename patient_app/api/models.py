from django.db import models
from django.contrib.auth.models import AbstractUser


#Custom User Model für das Abspeichern von Patienten Zugangsdaten
class CustomPatientUser(AbstractUser):
    @property
    def patient_id(self):  #function that creates a Users Patient ID (=the Patient ID that's used fort the Patient's FHIR Ressource)
        if self.id is None:
            return None
        return f"p{str(self.id).zfill(9)}"  ##gibt patient id mit p am anfang zurück, die immer 10 stellen hat (ID Spalte des User models mit Nullen aufgefüllt).zfill(9)}"  ##gibt patient id mit p am anfang zurück, die immer 10 stellen hat (ID Spalte des User models mit Nullen aufgefüllt)