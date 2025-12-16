import json
from fhir.resources.questionnaire import Questionnaire

json_obj = {
  "resourceType" : "Questionnaire",
  "id" : "f1",
  "url" : "https://www.med.upenn.edu/cbti/assets/user-content/documents/International%20Restless%20Legs%20Syndrome%20Study%20Group%20Rating%20Scale.pdf",
  "status" : "active",
  "subjectType" : ["Patient"],
  "title" : "International RLS Rating Scale",
  "date" : "2025",
  "item" : [{
    "linkId" : "1",
    "text" : "Wie würden Sie die Beschwerden in Ihren Beinen oder Armen insgesamt bewerten?",
    "type": "choice",
    "required": True,
    "answerOption": [
                {"valueString": "Keine Beschwerden"},
                {"valueString": "Leicht"},
                {"valueString": "Mittel"},
                {"valueString": "Stark"},
                {"valueString": "Sehr stark"}
    ]
  },
  {
    "linkId" : "2",
    "text" : "Wie stark ist Ihr Bewegungsdrang aufgrund der RLS-Beschwerden?",
    "type": "choice",
    "required": True,
    "answerOption": [
                {"valueString": "Kein Bewegungsdrang"},
                {"valueString": "Leicht"},
                {"valueString": "Mittel"},
                {"valueString": "Stark"},
                {"valueString": "Sehr stark"}
    ]
  },
  {
    "linkId" : "3",
    "text" : "Wie stark werden Ihre RLS-Beschwerden durch Bewegung gelindert?",
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
    "linkId" : "4",
    "text" : "Wie stark beeinträchtigen die RLS-Beschwerden Ihren Schlaf?",
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
    "linkId" : "5",
    "text" : "Wie müde oder schläfrig sind Sie tagsüber aufgrund der RLS-Beschwerden?",
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
    "linkId" : "6",
    "text" : "Wie stark ausgeprägt sind Ihre RLS-Beschwerden insgesamt?",
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
    "linkId" : "7",
    "text" : "Wie oft treten Ihre RLS-Beschwerden auf?",
    "type": "choice",
    "required": True,
    "answerOption": [
                {"valueString": "Nie"},
                {"valueString": "Selten"},
                {"valueString": "Mittel-oft"},
                {"valueString": "Oft"},
                {"valueString": "Sehr oft"}
    ]
  },
  {
    "linkId" : "8",
    "text" : "Wenn Sie RLS-Beschwerden haben, wie stark sind diese im Durchschnitt?",
    "type": "choice",
    "required": True,
    "answerOption": [
                {"valueString": "Sehr schwach"},
                {"valueString": "Schwach"},
                {"valueString": "Mittel"},
                {"valueString": "Stark"},
                {"valueString": "Sehr stark"}
    ]
  },
    {
    "linkId" : "9",
    "text" : "Wie stark beeinträchtigen die RLS-Beschwerden Ihre Fähigkeit, tägliche Aufgaben zu erledigen?",
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
    "linkId" : "10",
    "text" : "Wie stark beeinträchtigen die RLS-Beschwerden Ihre Stimmung?",
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


quest = Questionnaire(**json_obj)   #macht aus json_obj eine Questionnaire Ressource



import requests
server_url = "https://i-lv-prj-01.informatik.hs-ulm.de"

quest_object = quest.model_dump() 

#Verwendung von PUT um den Fragebogen genau an seine ID zu kriegen: https://stackoverflow.com/questions/107390/whats-the-difference-between-a-post-and-a-put-http-request
response = requests.put(
    server_url + "/Questionnaire/" + json_obj["id"], 
    json=quest_object,
    verify=False  #deaktiviert Zertifikat-Verifikation -> funktioniert für Self Signed Zertifikate
  )

print("Status:" + str(response.status_code))
print(response.content)

response = requests.get(server_url + "/Questionnaire/" + "f1", verify=False)

print("Status: " + str(response.status_code))
print(response.content)