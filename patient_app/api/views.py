from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from rest_framework.decorators import api_view, permission_classes
import json
import requests
from django.contrib.auth import get_user_model
from rest_framework_simplejwt.views import TokenObtainPairView
from .models import CustomPatientUser
from .serializers import UserRegisterSerializer, CustomTokenObtainPairSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import generics, permissions
from rest_framework.permissions import IsAuthenticated

#----------- Klassen für User Authentifizierung --------------------------------------------------------------

User = get_user_model()

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = UserRegisterSerializer
    permission_classes = [permissions.AllowAny]

class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer



#----------- Sonstige Views -----------------------------------------------------------------------------------

server_url = "https://i-lv-prj-01.informatik.hs-ulm.de"


#GET
@api_view(['GET'])  #Decorator. Macht aus Funktion rls_questionnaire eine API view, bei der nur GET requests möglich sind
@permission_classes([IsAuthenticated]) #API kann nur verwendet werden wenn User authentifiziert ist
def get_questionnaire(request, id):
    print(request.user.username)
    print(request.user.patient_id) #prints username + patient ID of anyone who uses the API View
    response = requests.get(server_url + "/Questionnaire/" + id, verify=False)  #holt Fragebogen im JSON Format vom FHIR Server
    rls_questionnaire=response.json()  #macht aus JSON ein Python Objekt (hier: ein Dictionary)
    return JsonResponse(rls_questionnaire)


#POST: Empfängt Patientendaten von Flutter Registrierung
@api_view(['POST'])  #Decorator. Macht aus Funktion post_patient eine API view, bei der nur POST requests möglich sind
def post_patient(request):
    patient_data = request.data
    user = CustomPatientUser.objects.get(username=patient_data["username"])  #Holt User mit dem jeweiligen Usernamen von dem CustomPatientUser Model
    user_patient_id = user.patient_id #lässt patient_id für diesen User berechnen

    # erstellt eine Fhir Patient Ressource mit der berechneten User ID + den vom Frontend empfangenen (bei der Registrierung eingegebenen) Daten
    fhir_patient = {
        "resourceType": "Patient",
        "id": user_patient_id,
        "name": [
            {
                "use": "official",
                "family": patient_data["nachname"],
                "given": [patient_data["vorname"]]
            }
        ],
        "birthDate": patient_data["geburtsdatum"]
    }

    #Verwendung von PUT um den Patienten genau an seine ID zu kriegen: https://stackoverflow.com/questions/107390/whats-the-difference-between-a-post-and-a-put-http-request
    response = requests.put(
        server_url + "/Patient/" + user_patient_id, 
        json=fhir_patient,
        verify=False) #verifizierung deaktiviert da wir ein selbst signiertes zertifikat verwenden

    print(response.content)

    return JsonResponse({
        "valid": True,
        "message": "Patient empfangen",
    })


#POST: Empfängt Antworten aus Flutter
@api_view(['POST'])  #Decorator. Macht aus Funktion rls_response eine API view, bei der nur POST requests möglich sind
@permission_classes([IsAuthenticated]) #API kann nur verwendet werden wenn User authentifiziert ist
def post_response(request):
    print(request.user.username)
    print(request.user.patient_id) #prints username + patient ID of anyone who uses the API View

    questionnaire_response = request.data

    #Score hinzufügen
    score = 0
    #Berechnung des Scores:
    for item in questionnaire_response["item"][1]["item"]:
        itemvalue = item["answer"][0]["valueString"][0]  #itemvalue = erste Stelle ([0]) von der gewählten Antwortmöglichkeit (valueString)
        score = score + int(itemvalue)   #castet itemvalue in Typ String und addiert den Wert zu score

    #an questionnaire_response dictionary anfügen:
    questionnaire_response["item"][0] = {
        "linkId": "0",
        "answer": [
            {"valueInteger": score}
        ]
    }

    # fügt Patient (mit id) als Quelle der Antworten hinzu
    questionnaire_response["source"] = {
        "reference" : "Patient/" + request.user.patient_id,
    }

    # hängt Patienten ID ans Ende der QuestionnaireResponse ID an
    questionnaire_response["id"] = questionnaire_response["id"] + request.user.patient_id


    print(questionnaire_response) #druckt Fragebogen Antwort ins Terminal aus

    #Verwendung von PUT um den Fragebogen genau an seine ID zu kriegen: https://stackoverflow.com/questions/107390/whats-the-difference-between-a-post-and-a-put-http-request
    response = requests.put(
        server_url + "/QuestionnaireResponse/" + questionnaire_response["id"], 
        json=questionnaire_response,
        verify=False) #verifizierung deaktiviert da wir eine selbst signiertes zertifikat verwenden

    print(response.content)
    
    return JsonResponse({
        "valid": True,
        "message": "Antwort akzeptiert",
        "score" : score
    })



@api_view(['GET'])  #Decorator
@permission_classes([IsAuthenticated]) #API kann nur verwendet werden wenn User authentifiziert ist
def get_questionnaire_response(request, date):  #Funktion alle RLS QuestionnaireResponses von einem bestimmten Tag zurückgibt
    print(request.user.username)
    print(request.user.patient_id) #prints username + patient ID of anyone who uses the API View
    
    responses_list = [] #erstellt eine leere Liste
    responses = requests.get(server_url + "/QuestionnaireResponse/?authored=" + date + "&source=Patient/" + request.user.patient_id, verify=False).json()  #holt alle Questionnaire_Responses vom gesuchten Tag vom gesuchten Patient (dem der die request gemacht hat) im JSON Format vom FHIR Server + macht daraus ein Python Dictionary
    if "entry" in responses:
        for r in responses["entry"]:
            questionnaire = requests.get(r["resource"]["questionnaire"], verify=False).json()
            question_list = []
            dictionary = {
                "responseid" : r["resource"]["id"],
                "questionnaireid" : questionnaire["id"],
                "date" : r["resource"]["authored"],
                "questionnairetitle" : questionnaire["title"],
                "numberofquestions" : len(questionnaire["item"][1]["item"]),
                "score" : r["resource"]["item"][0]["answer"][0]["valueInteger"],
                "maxscore" : questionnaire["item"][0]["extension"][0]["valueInteger"],

            }
            for n in range(dictionary["numberofquestions"]):
                question_list.append({
                    "question" : questionnaire["item"][1]["item"][n]["text"],
                    "answer" : r["resource"]["item"][1]["item"][n]["answer"][0]["valueString"]
                })
            dictionary["questions"] = question_list
            responses_list.append(dictionary)
    return JsonResponse(responses_list, safe=False)  #safe=False allows non-dict objects to be serialized