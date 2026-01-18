# Vorlage für das Löschen von FHIR Ressourcen

import requests

FHIR_SERVER = "https://i-lv-prj-01.informatik.hs-ulm.de"

HEADERS = {
    # falls Auth nötig:
    # "Authorization": "Bearer DEIN_TOKEN",
    "Content-Type": "application/fhir+json"
}

search_url = f"{FHIR_SERVER}/QuestionnaireResponse?_count=1000"

print("🔍 Lade QuestionnaireResponses...")
bundle = requests.get(search_url, headers=HEADERS, verify=False).json()

if "entry" not in bundle:
    print("✅ Keine QuestionnaireResponses gefunden.")
    exit()

deleted = 0

for entry in bundle["entry"]:
    res = entry.get("resource", {})
    qr_id = res.get("id")

    # 🔎 Interpretation sicher auslesen
    interpretation = None
    try:
        interpretation = res["item"][1]["answer"][0].get("valueString")
    except (KeyError, IndexError, TypeError):
        interpretation = None

    # ❌ Wenn keine Interpretation → löschen
    if not interpretation:
        print(f"🗑️ Lösche {qr_id} (keine Interpretation)")

        delete_url = f"{FHIR_SERVER}/QuestionnaireResponse/{qr_id}"
        r = requests.delete(delete_url, headers=HEADERS, verify=False)

        if r.status_code in [200, 204]:
            deleted += 1
        else:
            print(f"⚠️ Fehler bei {qr_id}: {r.status_code}")

print(f"\n✅ Fertig. {deleted} QuestionnaireResponses gelöscht.")

'''
import requests
server_url = "https://i-lv-prj-01.informatik.hs-ulm.de"


response = requests.delete(
    server_url + "/QuestionnaireResponse/" + "rf220261813944p000000009", 
    verify=False  #deaktiviert Zertifikat-Verifikation -> funktioniert für Self Signed Zertifikate
  )
'''


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


