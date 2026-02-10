# Vorlage für das Löschen von FHIR Ressourcen


import requests
server_url = "https://i-lv-prj-01.informatik.hs-ulm.de"


response = requests.delete(
    server_url + "/QuestionnaireResponse/" + "rf1202612023125p000000009", 
    verify=False  #deaktiviert Zertifikat-Verifikation -> funktioniert für Self Signed Zertifikate
  )



'''
response = requests.delete(
    server_url + "/QuestionnaireResponse/" + "rf22026114172649p000000009", 
    verify=False  #deaktiviert Zertifikat-Verifikation -> funktioniert für Self Signed Zertifikate
  )

response = requests.delete(
    server_url + "/QuestionnaireResponse/" + "rf22026114172610p000000009", 
    verify=False  #deaktiviert Zertifikat-Verifikation -> funktioniert für Self Signed Zertifikate
  )

response = requests.delete(
    server_url + "/QuestionnaireResponse/" + "rf22026114172457p000000009", 
    verify=False  #deaktiviert Zertifikat-Verifikation -> funktioniert für Self Signed Zertifikate
  )

response = requests.delete(
    server_url + "/QuestionnaireResponse/" + "rf22026114172251p000000009", 
    verify=False  #deaktiviert Zertifikat-Verifikation -> funktioniert für Self Signed Zertifikate
  )


response = requests.delete(
    server_url + "/QuestionnaireResponse/" + "rf12026114172117p000000009", 
    verify=False  #deaktiviert Zertifikat-Verifikation -> funktioniert für Self Signed Zertifikate
  )
'''


