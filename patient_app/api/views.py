from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json

#Fragebogen
RLS_QUESTIONNAIRE = {
    "resourceType": "Questionnaire",
    "id": "rls-qol",
    "title": "RLS Quality of Life Questionnaire",
    "status": "active",
    "item": [
        {
            "linkId": "q1",
            "text": "Wie stark haben die RLS-Symptome Ihre Schlafqualität beeinträchtigt?",
            "type": "choice",
            "required": True,
            "answerOption": [
                {"valueString": "Gar nicht"},
                {"valueString": "Leicht"},
                {"valueString": "Mittel"},
                {"valueString": "Stark"},
                {"valueString": "Sehr stark"}
            ]
        },
        {
            "linkId": "q2",
            "text": "Wie stark haben die RLS-Symptome Ihre Stimmung beeinträchtigt?",
            "type": "choice",
            "required": True,
            "answerOption": [
                {"valueString": "Gar nicht"},
                {"valueString": "Leicht"},
                {"valueString": "Mittel"},
                {"valueString": "Stark"},
                {"valueString": "Sehr stark"}
            ]
        }
    ]
}

#Validierung
def validate_response(questionnaire_json, response_json):
    errors = []

    if response_json.get("resourceType") != "QuestionnaireResponse":
        errors.append("resourceType muss QuestionnaireResponse sein.")

    if response_json.get("questionnaire") != questionnaire_json.get("id"):
        errors.append("questionnaire ID stimmt nicht.")

    q_items = {item["linkId"]: item for item in questionnaire_json["item"]}
    r_items = {item["linkId"]: item for item in response_json.get("item", [])}

    for link_id, q in q_items.items():
        if q.get("required") and link_id not in r_items:
            errors.append(f"Pflichtfrage ohne Antwort: {link_id}")

    return errors


#GET
def rls_questionnaire(request):
    return JsonResponse(RLS_QUESTIONNAIRE)


#POST
@csrf_exempt
def rls_response(request):
    if request.method != "POST":
        return JsonResponse({"error": "Nur POST erlaubt"}, status=400)

    try:
        body = json.loads(request.body)
    except:
        return JsonResponse({"error": "Ungültiges JSON"}, status=400)

    errors = validate_response(RLS_QUESTIONNAIRE, body)
    if errors:
        return JsonResponse({"valid": False, "errors": errors}, status=400)

    return JsonResponse({
        "valid": True,
        "message": "Antwort akzeptiert",
        "received": body
    })

