import json
from fhir.resources.questionnaire import Questionnaire

json_obj = {
  "resourceType" : "Questionnaire",
  "id" : "ternaehrung",
  "status" : "active",
  "subjectType" : ["Patient"],
  "title" : "Ernährung Fragebogen",
  "date" : "2025",
  "purpose" : "tagebuch",
  "item" : [{
    "linkId" : "0",
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
    "linkId" : "1",
    "text" : "Fragebogen Fragen",
    "type" : "group",
    "item" : [{
        "linkId" : "1.1",
        "text" : "Eisen-/nährstoffreich gegessen? (Fleisch/Fisch oder Hülsenfrüchte + grünes Gemüse)",
        "type": "choice",
        "required": True,
        "answerOption": [
                    {"valueString": "0Nichts"},
                    {"valueString": "1Wenig"},
                    {"valueString": "2Viel"}
        ]
      },
      {
        "linkId" : "1.2",
        "text" : "Magnesiumreich gegessen? (Nüsse, Samen, Vollkorn, Hülsenfrüchte)",
        "type": "choice",
        "required": True,
        "answerOption": [
                    {"valueString": "0Nichts"},
                    {"valueString": "2Wenig"},
                    {"valueString": "1Viel"}
        ]
      },
      {
        "linkId" : "1.3",
        "text" : "Wie hoch war Ihr Koffeinkonsum heute?",
        "type": "choice",
        "required": True,
        "answerOption": [
                    {"valueString": "0Hoch"},
                    {"valueString": "1Niedrig"},
                    {"valueString": "2Nichts"}
        ]
      },
        {
        "linkId" : "1.4",
        "text" : "Wie hoch war Ihr Alkoholkonsum (v. a. abends)?",
        "type": "choice",
        "required": True,
        "answerOption": [
                    {"valueString": "0Hoch"},
                    {"valueString": "1Niedrig"},
                    {"valueString": "2Nichts"}
        ]
      },
        {
        "linkId" : "1.5",
        "text" : "Wie waren Ihre RLS-Symptome heute im Vergleich zu üblich?",
        "type": "choice",
        "required": True,
        "answerOption": [
                    {"valueString": "0Schlechter"},
                    {"valueString": "1Wie üblich"},
                    {"valueString": "2Besser"}
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