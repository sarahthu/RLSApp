import json
from fhir.resources.questionnaire import Questionnaire

json_obj = {
  "resourceType" : "Questionnaire",
  "id" : "f2",
  "url" : "https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://www.med.upenn.edu/cbti/assets/user-content/documents/Restless%2520Legs%2520Syndrome%2520Quality%2520of%2520Life%2520Questionnaire%2520(PLSQoL).pdf&ved=2ahUKEwih6arp0p-RAxVo87sIHb7VHIgQFnoECBwQAQ&usg=AOvVaw0OIlAp2hDXbzY99L9Uh5Dl",
  "status" : "active",
  "subjectType" : ["Patient"],
  "title" : "RLS Quality of Life Questionnaire",
  "date" : "2025",
  "purpose" : "fragebogen",
  "item" : [{
    "linkId" : "0",
    "text" : "Score",
    "type" : "integer",
    "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/maxValue",
          "valueInteger": 20
        }
      ]
    },
    {
    "linkId" : "1",
    "text" : "Fragebogen Fragen",
    "type" : "group",
    "item" : [{
        "linkId" : "1.1",
        "text" : "Wie sehr fühlen Sie sich durch Ihr RLS belastet?",
        "type": "choice",
        "required": True,
        "answerOption": [
                    {"valueString": "0Gar nicht"},
                    {"valueString": "1Leicht"},
                    {"valueString": "2Mittel"},
                    {"valueString": "3Stark"},
                    {"valueString": "4Sehr stark"}
        ]
      },
      {
        "linkId" : "1.2",
        "text" : "Wie oft in den letzten 4 Wochen hat Sie Ihr RLS von abendlichen sozialen Aktivitäten abgehalten?",
        "type": "choice",
        "required": True,
        "answerOption": [
                    {"valueString": "0Gar nicht"},
                    {"valueString": "1Selten"},
                    {"valueString": "2Manchmal"},
                    {"valueString": "3Meistens"},
                    {"valueString": "4Immer"}
        ]
      },
      {
        "linkId" : "1.3",
        "text" : "Wie oft in den letzten 4 Wochen wurde Ihre Fähigkeit gute Entscheidungen zu treffen durch Schlafprobleme beeinträchtigt?",
        "type": "choice",
        "required": True,
        "answerOption": [
                    {"valueString": "0Gar nicht"},
                    {"valueString": "1Selten"},
                    {"valueString": "2Manchmal"},
                    {"valueString": "3Oft"},
                    {"valueString": "4Sehr oft"}
        ]
      },
        {
        "linkId" : "1.4",
        "text" : "Wie oft in den letzten 4 Wochen hat Ihr RLS Sie bei der Ausführung von täglichen Aktivitäten behindert, beispielsweise dabei ein zufriedenstellendes Familien-, Haushalts-, Sozial-, Schul- oder Berufsleben zu führen?",
        "type": "choice",
        "required": True,
        "answerOption": [
                    {"valueString": "0Gar nicht"},
                    {"valueString": "1Selten"},
                    {"valueString": "2Manchmal"},
                    {"valueString": "3Oft"},
                    {"valueString": "4Sehr oft"}
        ]
      },
        {
        "linkId" : "1.5",
        "text" : "Wie oft in den letzen 4 Wochen hatten Sie wegen Ihrem RLS Schwierigkeiten einen vollen Tag zu arbeiten?",
        "type": "choice",
        "required": True,
        "answerOption": [
                    {"valueString": "0Gar nicht"},
                    {"valueString": "1Selten"},
                    {"valueString": "2Manchmal"},
                    {"valueString": "3Meistens"},
                    {"valueString": "4Immer"}
        ]
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

response = requests.get(server_url + "/Questionnaire/" + "f2", verify=False)

print("Status: " + str(response.status_code))
print(response.content)