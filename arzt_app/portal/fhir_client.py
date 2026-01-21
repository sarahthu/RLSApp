# doctors/fhir_client.py
import re
import requests
from django.conf import settings


# Basics: Headers & Helfer Funktionen
#Erstellt die Standard-HTTP-Header für alle FHIR-Requests.
def _headers():
    headers = {"Accept": "application/fhir+json", #sagt dem Server, dass wir FHIR-JSON erwart
               "Content-Type": "application/fhir+json",} #sagt dem Server, dass wir FHIR-JSON senden
    token = getattr(settings, "FHIR_AUTH_TOKEN", "")
    if token:
        headers["Authorization"] = f"Bearer {token}"
    return headers

#Extrahiert die Questionnaire-ID aus verschiedenen möglichen Referenzen
def _questionnaire_id_from_ref(ref: str) -> str:
    if not ref:
        return ""
    ref = ref.split("|", 1)[0].strip()
    # Vollständige URL mit /Questionnaire/
    if "/Questionnaire/" in ref:
        return ref.split("/Questionnaire/", 1)[1].split("/", 1)[0]
    # Kurzform "Questionnaire/f1"
    if ref.startswith("Questionnaire/"):
        return ref.split("/", 1)[1]
    return ref

#Extrahiert die Patient-ID aus einer Patient-Referenz.
def _patient_id_from_reference(ref: str) -> str:
    if not ref:
        return ""
    if "/Patient/" in ref:
        return ref.split("/Patient/", 1)[1].split("/", 1)[0]
    if ref.startswith("Patient/"):
        return ref.split("/", 1)[1]
    return ""

#Extrahiert die Practitioner-ID aus einer Practitioner-Referenz, wird benötigt für filtern?!
def _practitioner_id_from_reference(ref: str) -> str:
    if not ref:
        return ""
    if "/Practitioner/" in ref:
        return ref.split("/Practitioner/", 1)[1].split("/", 1)[0]
    if ref.startswith("Practitioner/"):
        return ref.split("/", 1)[1]
    return ""

# Patients

#Lädt eine Liste von Patienten vom FHIR-Serve

def fetch_patients(count=25, search=None, practitioner_id=None): #count: maximale Anzahl an Patienten,search: optionaler Suchstring für den Namen
    base = settings.FHIR_BASE_URL.rstrip("/") # Basis-URL des FHIR-Servers (
    url = f"{base}/Patient"

    params = {"_count": count}
    if search:
        params["name"] = search

# HTTP-GET Request an den FHIR-Server
    r = requests.get(
        url,
        headers=_headers(), # Standard-FHIR-Header
        params=params, # Query-Parameter
        timeout=getattr(settings, "FHIR_TIMEOUT", 10),
        verify=getattr(settings, "FHIR_VERIFY_SSL", True),
    )
    r.raise_for_status()
    bundle = r.json() # FHIR-Antwort ist ein Bundle

    patients = []
# Durch alle Einträge im Bundle iterieren
    for entry in bundle.get("entry", []):
        res = entry.get("resource", {})
        if res.get("resourceType") != "Patient": # Nur Patient-Ressourcen berücksichtigen
            continue

        #FILTER: gehört Patient zu Practitioner?
        '''if practitioner_id:
            gp_list = res.get("generalPractitioner", []) or []
            gp_ids = []
            for gp in gp_list:
                gp_ids.append(_extract_practitioner_id_from_ref(gp.get("reference", "")))

            if practitioner_id not in gp_ids:
                continue'''

        pid = res.get("id", "") #Patient-ID aus der Ressourc
        name = pid
        names = res.get("name", []) # Name aus Patient.name[] extrahieren
        if names:
            n = names[0]
            given = " ".join(n.get("given", [])) #vorname
            family = n.get("family", "")         #nachname
            name = (given + " " + family).strip() or pid
        # Vereinfachte Patient-Daten für die UI
        patients.append({
            "id": pid,
            "name": name,
            "gender": res.get("gender", "-"),
            "birthDate": res.get("birthDate", "-"),
        })

    return patients


def fhir_list_patients(count=25, search=None):
    #Alias, damit bestehender Code nicht crasht
    return fetch_patients(count=count, search=search)


def fetch_patient_by_id(patient_id: str) -> dict:
    #Lädt Patient Ressource direkt über /Patient/<id>
    base = settings.FHIR_BASE_URL.rstrip("/")
    url = f"{base}/Patient/{patient_id}"

    r = requests.get(
        url,
        headers=_headers(),
        timeout=getattr(settings, "FHIR_TIMEOUT", 10),
        verify=getattr(settings, "FHIR_VERIFY_SSL", True),
    )
    r.raise_for_status()
    return r.json()

'''
# Practitioner Filter QR.source -> Patient -> generalPractitioner

def _patient_belongs_to_practitioner(patient_resource: dict, practitioner_id: str) -> bool:
    #Prüft ob Patient.generalPractitioner den gewünschten Practitioner enthält
    if not practitioner_id:
        return False

    gp_list = patient_resource.get("generalPractitioner", []) or [] #Holt die Liste generalPractitioner aus der Patient-Ressourc
    for gp in gp_list: #Geht jeden Eintrag durch und liest
        ref = gp.get("reference", "")
        gp_id = _practitioner_id_from_reference(ref)
        if gp_id == practitioner_id:
            return True
    return False

#Ermittelt alle Patienten, die zu einem bestimmten Arzt gehören
def fetch_patient_ids_for_practitioner_via_qr_source(practitioner_id: str) -> set[str]:
    """- alle QuestionnaireResponses geladen werden
    - aus qr.source.reference die Patient-ID extrahiert wird
    - Patient geladen wird
    - geprüft wird: patient.generalPractitioner enthält practitioner_id"""
    if not practitioner_id:
        return set()

    base = settings.FHIR_BASE_URL.rstrip("/")
    qr_url = f"{base}/QuestionnaireResponse"

    r = requests.get(
        qr_url,
        headers=_headers(),
        params={"_count": 500},
        timeout=getattr(settings, "FHIR_TIMEOUT", 10),
        verify=getattr(settings, "FHIR_VERIFY_SSL", True),
    )
    r.raise_for_status()
    bundle = r.json()

    patient_ids: set[str] = set() #patient_ids → Ergebnis (keine Duplikate)
    patient_cache: dict[str, dict] = {} #patient_cache → Patienten nur einmal vom Server laden
    #Iteriert alle QuestionnaireResponses
    for entry in bundle.get("entry", []):
        qr = entry.get("resource", {}) 
        if qr.get("resourceType") != "QuestionnaireResponse":
            continue

        src_ref = (qr.get("source") or {}).get("reference", "") #Holt Patient-ID aus qr.source.reference
        pid = _patient_id_from_reference(src_ref)
        if not pid:
            continue

        if pid not in patient_cache:
            patient_cache[pid] = fetch_patient_by_id(pid)

        if _patient_belongs_to_practitioner(patient_cache[pid], practitioner_id):
            patient_ids.add(pid)

    return patient_ids'''


# ------------------------------------------------------------
# Questionnaires & Responses
# ------------------------------------------------------------

#Lädt eine Questionnaire-Ressource vom FHIR-Server
def fetch_questionnaire_by_id(qid: str) -> dict:
    """Lädt Questionnaire über /Questionnaire/<id>."""
    base = settings.FHIR_BASE_URL.rstrip("/")
    url = f"{base}/Questionnaire/{qid}"

    r = requests.get(
        url,
        headers=_headers(),
        timeout=getattr(settings, "FHIR_TIMEOUT", 10),
        verify=getattr(settings, "FHIR_VERIFY_SSL", True),
    )
    r.raise_for_status()
    return r.json() #JSON des Questionnaires zurückgeben

#Baut eine Map (Dictionary): linkId -> Frage-Text
def build_question_text_map(questionnaire: dict) -> dict:
    mapping = {}

    def walk(items):
        for it in items or []:
            link_id = it.get("linkId") # eindeutige ID der Frage
            text = it.get("text")  # Fragetext
            if link_id and text:   # Nur speichern, wenn beides existiert
                mapping[link_id] = text
            walk(it.get("item", []))

    walk(questionnaire.get("item", [])) # Start: oberste Ebene im Questionnaire
    return mapping

#link liefert Bundle mit QuestionnaireResponses eines Patienten
def fetch_questionnaires_for_patient_from_link(link: str):
    r = requests.get(
        link,
        headers=_headers(),
        timeout=getattr(settings, "FHIR_TIMEOUT", 10),
        verify=getattr(settings, "FHIR_VERIFY_SSL", True),
    )
    r.raise_for_status()
    bundle = r.json()

    labels = getattr(settings, "QUESTIONNAIRE_LABELS", {}) # schöne Anzeigenamen aus settings.py
    seen = set() # damit man jeden Fragebogen nur einmal listen
    out = [] #Ergebnis

    for entry in bundle.get("entry", []):
        qr = entry.get("resource", {})
        if qr.get("resourceType") != "QuestionnaireResponse": # Sicherheit nur QuestionnaireResponse verarbeiten
            continue

        qref = qr.get("questionnaire", "")
        qid = _questionnaire_id_from_ref(qref)
        if not qid or qid in seen:
            continue
        seen.add(qid)
        # speichern: id + label + response_id
        out.append({
            "id": qid,
            "label": labels.get(qid, qid),
            "response_id": qr.get("id", ""),
        })

    # Wunsch-Reihenfolge
    order = ["f1", "f2", "tachtsamkeit", "tsport", "ternaehrung"]
    out.sort(key=lambda x: order.index(x["id"]) if x["id"] in order else 999)
    return out

#Holt eine bestimmte QuestionnaireResponse anhand ihrer ID (Wenn man in der Historie auf "Ansehen" klickt, ann brauchst man die konkrete Response, um Fragen+Antworten zu zeigen)
def fetch_questionnaire_response_by_id(response_id: str) -> dict:
    base = settings.FHIR_BASE_URL.rstrip("/")
    url = f"{base}/QuestionnaireResponse/{response_id}"

    r = requests.get(
        url,
        headers=_headers(),
        timeout=getattr(settings, "FHIR_TIMEOUT", 10),
        verify=getattr(settings, "FHIR_VERIFY_SSL", True),
    )
    r.raise_for_status()
    return r.json()

#-----------------------------------------------------------------------
#Aus einer QuestionnaireResponse (qr) den Score und die Interpretation rausholen
def _extract_score_and_interpretation(qr: dict):
    score = None #speichern später den Score
    interpretation = None

#Diese Funktion sucht das erste Feld, das mit "value" beginnt und gibt dessen Inhalt zurück
    def parse_value(ans: dict):
        for k, v in ans.items():
            if k.startswith("value"):
                return v
        return None
    # Es werden alle Items durchlaufen
    def walk(items):
        nonlocal score, interpretation # damit score/interpretation aus der äußeren Funktion setzen kann
        for it in items or []:
            link_id = it.get("linkId", "")
            answers = it.get("answer", []) or [] # Liste von Antworten
             # Wenn es mindestens eine Antwort gibt:
            if answers:
                v = parse_value(answers[0])
                if link_id == "0.1" and score is None: # Falls linkId=0.1 und score noch nicht gesetzt -> score speichern
                    score = v
                if link_id == "0.2" and interpretation is None: # Falls linkId=0.2 und interpretation noch nicht gesetzt -> interpretation speichern
                    interpretation = v
            walk(it.get("item", []))

    walk(qr.get("item", [])) # Startpunkt: qr["item"] enthält die Liste der Questions/Items
    return score, interpretation # Ergebnis

#Macht aus einer QuestionnaireResponse eine Liste
def answers_from_questionnaire_response(questionnaire_id: str, qr: dict):
    questionnaire = fetch_questionnaire_by_id(questionnaire_id) #Questionnaire laden 
    text_map = build_question_text_map(questionnaire) #linkId -> text Map bauen

#Nimmt ein answer-Objekt aus FHIR und macht daraus einen String
    def parse_value(answer_obj: dict) -> str:
        for k, v in answer_obj.items():
            if not k.startswith("value"):
                continue
            if isinstance(v, str):
                # z.b. "2Mittel" -> "2 Mittel"
                return re.sub(r"^(\d+)(\D+)", r"\1 \2", v)
            return str(v)
        return ""

    results = []

    def walk_items(items):
        for it in items or []:
            link_id = it.get("linkId", "")
            question_text = it.get("text") or text_map.get(link_id) or link_id or "(ohne Frage)"

            answers = [parse_value(a) for a in (it.get("answer", []) or [])] # Antworten auslesen und zu Strings machen
            answers = [a for a in answers if a != ""]

# Nur speichern, wenn überhaupt Antworten existieren
            if answers:
                results.append({
                    "linkId": link_id,
                    "question": question_text,
                    "answers": answers,
                })

            walk_items(it.get("item", []))

    walk_items(qr.get("item", []))
    return results

#Ruft über 'link' ein Bundle von QuestionnaireResponses für EINEN Patienten ab
def fetch_questionnaire_answers_for_patient(link: str, questionnaire_id: str):

    #Questionnaire laden, damit man den Fragetext zu linkId bekommen
    questionnaire = fetch_questionnaire_by_id(questionnaire_id)
    text_map = build_question_text_map(questionnaire)
    
    #QuestionnaireResponses-Bundle vom Server holen
    r = requests.get(
        link,
        headers=_headers(),
        timeout=getattr(settings, "FHIR_TIMEOUT", 10),
        verify=getattr(settings, "FHIR_VERIFY_SSL", True),
    )
    r.raise_for_status()
    bundle = r.json()

#eine Antwort in String umwandeln
    def parse_value(answer_obj: dict) -> str:
        for k, v in answer_obj.items():
            if k.startswith("value"):
                if isinstance(v, str):
                    return re.sub(r"^(\d+)(\D+)", r"\1 \2", v)
                return str(v)
        return ""

    results = []

    def walk_items(items):
        for it in items or []:
            link_id = it.get("linkId", "")
            question_text = it.get("text") or text_map.get(link_id) or link_id or "(ohne Frage)"

            answers = [parse_value(a) for a in (it.get("answer", []) or [])]
            answers = [a for a in answers if a != ""]

            if answers:
                results.append({
                    "linkId": link_id,
                    "question": question_text,
                    "answers": answers,
                })

            walk_items(it.get("item", []))

    for entry in bundle.get("entry", []):
        qr = entry.get("resource", {})
        if qr.get("resourceType") != "QuestionnaireResponse":
            continue

        qref = qr.get("questionnaire", "")
        qid = _questionnaire_id_from_ref(qref)
        if qid != questionnaire_id:
            continue

        walk_items(qr.get("item", []))

    return results

#Holt den neuesten Score über einen funktionierenden Patient-Link (FHIR_QR_LINK_TEMPLATE).
def fetch_latest_score_for_patient(patient_id: str, questionnaire_id: str):
    #Link bauen der für einen Patienten alle QuestionnaireResponses liefert
    qr_link = settings.FHIR_QR_LINK_TEMPLATE.format(id=patient_id)

    summaries = fetch_questionnaire_response_summaries_for_patient(qr_link, questionnaire_id)
    if not summaries:
        return "-"

    latest = summaries[0]  # ist neueste 
    score = latest.get("score") #Score aus dem dict lesen
    return str(score) if score is not None else "-"

#Liefert eine Historie aller QuestionnaireResponses eines Patientenfür einen bestimmten Fragebogen
def fetch_questionnaire_response_summaries_for_patient(link: str, questionnaire_id: str):

    r = requests.get(
        link,
        headers=_headers(),
        timeout=getattr(settings, "FHIR_TIMEOUT", 10),
        verify=getattr(settings, "FHIR_VERIFY_SSL", True),
    )
    r.raise_for_status()
    bundle = r.json()

    out = []

    for entry in bundle.get("entry", []):
        qr = entry.get("resource", {}) 
        if qr.get("resourceType") != "QuestionnaireResponse": #nur QuestionnaireResponse verarbeiten
            continue
      
       #Prüfen: gehört die Response zu unserem questionnaire_id
        qref = qr.get("questionnaire", "")
        qid = _questionnaire_id_from_ref(qref)
        if qid != questionnaire_id:
            continue
        #Score + Interpretation aus der Response rausholen
        score, interpretation = _extract_score_and_interpretation(qr)

        out.append({
            "id": qr.get("id", ""),
            "authored": qr.get("authored") or qr.get("meta", {}).get("lastUpdated") or "",
            "score": score,
            "interpretation": interpretation,
        })

    out.sort(key=lambda x: x["authored"] or "", reverse=True)
    return out
