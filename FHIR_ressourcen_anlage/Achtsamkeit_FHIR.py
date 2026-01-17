# verwenden wir doch nicht mehr als Kategorie!

import json
from fhir.resources.questionnaire import Questionnaire

json_obj = {
  "resourceType" : "Questionnaire",
  "id" : "tachtsamkeit",
  "status" : "active",
  "subjectType" : ["Patient"],
  "title" : "Achtsamkeit Fragebogen",
  "date" : "2025",
  "purpose" : "tagebuch",
  "item" : [{
    "linkId" : "0.1",
    "text" : "Score",
    "type" : "integer",
    "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/maxValue",
          "valueInteger": 10
        }
      ]
    },
    {
        "linkId" : "0.2",
        "text" : "Score Interpretation",
        "type": "string",
    },
    {
    "linkId" : "1",
    "text" : "Fragebogen Fragen",
    "type" : "group",
    "item" : [{
        "linkId" : "1.1",
        "text" : "Wie stark waren ihre RLS-Symptome heute insgesamt?",
        "type": "choice",
        "required": True,
        "answerOption": [
                    {"valueString": "2Gering"},
                    {"valueString": "1Mittel"},
                    {"valueString": "0Stark"}
        ]
      },
      {
        "linkId" : "1.2",
        "text" : "Wie lange/oft waren die Symptome heute deutlich spürbar?",
        "type": "choice",
        "required": True,
        "answerOption": [
                    {"valueString": "0Häufig / lange"},
                    {"valueString": "1Zeitweise"},
                    {"valueString": "2Kurz / selten"}
        ]
      },
      {
        "linkId" : "1.3",
        "text" : "Wie oft haben Sie heute Achtsamkeitsübungen durchgeführt?",
        "type": "choice",
        "required": True,
        "answerOption": [
                    {"valueString": "0Gar nicht"},
                    {"valueString": "1Einmal kurz (<10 Minuten)"},
                    {"valueString": "2Mehrmals oder länger (>10 Minuten)"}
        ]
      },
        {
        "linkId" : "1.4",
        "text" : "Wie war Ihr Stressniveau heute?",
        "type": "choice",
        "required": True,
        "answerOption": [
                    {"valueString": "0Hoch"},
                    {"valueString": "1Mittel"},
                    {"valueString": "2Niedrig"}
        ]
      },
        {
        "linkId" : "1.5",
        "text" : "Wie erholt waren Sie heute insgesamt?",
        "type": "choice",
        "required": True,
        "answerOption": [
                    {"valueString": "0Gar nicht erholt"},
                    {"valueString": "1Mittel"},
                    {"valueString": "2Sehr erholt"}
        ]
      }]
    },
    {
    "linkId" : "2",
    "text" : "Tagebucheinträge",
    "type" : "group",
    "item" : [{
        "linkId" : "2.1",
        "text" : "öffentlich",
        "type": "text",
      },
      {
        "linkId" : "2.2",
        "text" : "privat",
        "type": "text",
      }]
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

response = requests.get(server_url + "/Questionnaire/" + "tachtsamkeit", verify=False)

print("Status: " + str(response.status_code))
print(response.content)