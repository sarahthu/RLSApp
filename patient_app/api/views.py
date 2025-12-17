from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from rest_framework.decorators import api_view
import json
import requests


server_url = "https://i-lv-prj-01.informatik.hs-ulm.de"


'''
#Validierung
def validate_response(questionnaire_json, response_json):
    errors = []

    #Prüft, ob die richtige FHIR-Ressource gesendet wird
    if response_json.get("resourceType") != "QuestionnaireResponse":
        errors.append("resourceType muss QuestionnaireResponse sein.")

     #Prüft, ob die Antwort zum richtigen Fragebogen gehört
    if response_json.get("questionnaire") != questionnaire_json.get("id"):
        errors.append("questionnaire ID stimmt nicht.")

    #Fragebogen-Fragen als Dictionary
    q_items = {item["linkId"]: item for item in questionnaire_json["item"]}
    r_items = {item["linkId"]: item for item in response_json.get("item", [])}

    #Alle Pflichtfragen müssen beantwortet sein
    for link_id, q in q_items.items():
        if q.get("required") and link_id not in r_items:
            errors.append(f"Pflichtfrage ohne Antwort: {link_id}")

    return errors
'''

#GET
@api_view(['GET'])  #Decorator. Macht aus Funktion rls_questionnaire eine API view, bei der nur GET requests möglich sind
def get_questionnaire(request, id):
    response = requests.get(server_url + "/Questionnaire/" + id, verify=False)  #holt Fragebogen im JSON Format vom FHIR Server
    RLS_QUESTIONNAIRE=response.json()  #macht aus JSON ein Python Objekt (hier: ein Dictionary)
    return JsonResponse(RLS_QUESTIONNAIRE)


#POST: Empfängt und prüft die Antworten aus Flutter
@csrf_exempt
@api_view(['POST'])  #Decorator. Macht aus Funktion rls_response eine API view, bei der nur POST requests möglich sind
def post_response(request):
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
def get_questionnaire_response(request, date):  #Funktion alle RLS QuestionnaireResponses von einem bestimmten Tag zurückgibt
    responses_list = [] #erstellt eine leere Liste
    responses = requests.get(server_url + "/QuestionnaireResponse/?authored=" + date, verify=False).json()  #holt alle Questionnaire_Responses vom gesuchten Tag im JSON Format vom FHIR Server + macht daraus ein Python Dictionary
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