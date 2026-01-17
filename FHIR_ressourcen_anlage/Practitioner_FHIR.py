import requests

server_url = "https://i-lv-prj-01.informatik.hs-ulm.de"


fhir_practitioner = {
        "resourceType": "Practitioner",
        "id": "678964456",
        "name" : [{
            "use": "official",
            "family" : "Scholz",
            "given" : ["Noah"],
            "prefix" : ["Dr"]
        }],
}

response = requests.put(
        server_url + "/Practitioner/" + fhir_practitioner["id"], 
        json=fhir_practitioner,
        verify=False) #verifizierung deaktiviert da wir ein selbst signiertes zertifikat verwenden
