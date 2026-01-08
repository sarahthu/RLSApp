import json
from fhir.resources.questionnaire import Questionnaire

json_obj = {
  "resourceType" : "Questionnaire",
  "id" : "tsport",
  "status" : "active",
  "subjectType" : ["Patient"],
  "title" : "Sport Fragebogen",
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
        "text" : "Wie aktiv waren Sie heute insgesamt?",
        "type": "choice",
        "required": True,
        "answerOption": [
                    {"valueString": "0Wenig"},
                    {"valueString": "1Mittel"},
                    {"valueString": "2Viel"}
        ]
      },
      {
        "linkId" : "1.2",
        "text" : "Wie anstrengend war die stärkste Aktivität heute?",
        "type": "choice",
        "required": True,
        "answerOption": [
                    {"valueString": "0Intensiv"},
                    {"valueString": "2Moderat"},
                    {"valueString": "1Leicht"}
        ]
      },
      {
        "linkId" : "1.3",
        "text" : "Wann war Ihre stärkste Aktivität heute?",
        "type": "choice",
        "required": True,
        "answerOption": [
                    {"valueString": "0Abends"},
                    {"valueString": "1Mittags"},
                    {"valueString": "2Morgens"}
        ]
      },
        {
        "linkId" : "1.4",
        "text" : "Wie haben sich Ihre RLS-Symptome heute Abend/Nacht entwickelt?",
        "type": "choice",
        "required": True,
        "answerOption": [
                    {"valueString": "0Schlechter als üblich"},
                    {"valueString": "1Wie üblich"},
                    {"valueString": "2Besser als üblich"}
        ]
      },
        {
        "linkId" : "1.5",
        "text" : "Wie war Ihr Schlaf letzte Nacht?",
        "type": "choice",
        "required": True,
        "answerOption": [
                    {"valueString": "0Schlecht"},
                    {"valueString": "1Mittel"},
                    {"valueString": "2Gut"}
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