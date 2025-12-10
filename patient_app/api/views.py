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
    response = requests.get(server_url + "/Questionnaire/" + id, verify=False)  #holt Patientendaten im JSON Format vom FHIR Server
    RLS_QUESTIONNAIRE=response.json()  #macht aus JSON ein Python Objekt (hier: ein Dictionary)
    return JsonResponse(RLS_QUESTIONNAIRE)


#POST: Empfängt und prüft die Antworten aus Flutter
@csrf_exempt
@api_view(['POST'])  #Decorator. Macht aus Funktion rls_response eine API view, bei der nur POST requests möglich sind
def post_response(request):
    questionnaire_reponse = request.data

    print(questionnaire_reponse) #druckt Fragebogen Antwort ins Terminal aus

    #Verwendung von PUT um den Fragebogen genau an seine ID zu kriegen: https://stackoverflow.com/questions/107390/whats-the-difference-between-a-post-and-a-put-http-request
    response = requests.put(
        server_url + "/QuestionnaireResponse/" + questionnaire_reponse["id"], 
        json=questionnaire_reponse,
        verify=False) #verifizierung deaktiviert da wir eine selbst signiertes zertifikat verwenden

    print(response.content)

    '''
    if request.method != "POST":
        return JsonResponse({"error": "Nur POST erlaubt"}, status=400)

    try:
        body = json.loads(request.body)
    except:
        return JsonResponse({"error": "Ungültiges JSON"}, status=400)

    errors = validate_response(RLS_QUESTIONNAIRE, body)
    if errors:
        return JsonResponse({"valid": False, "errors": errors}, status=400)
    '''
    
    return JsonResponse({
        "valid": True,
        "message": "Antwort akzeptiert",
        #"received": body
    })


