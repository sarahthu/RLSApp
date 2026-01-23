import re 
import requests
from django.conf import settings

# Basics: Header + kleine Helper

# Erstellt die HTTP-Header für FHIR-Requests
def _headers():
    headers = {"Accept": "application/fhir+json","Content-Type": "application/fhir+json",}

# Token aus Django settings laden
    token = getattr(settings, "FHIR_AUTH_TOKEN", "")
    if token:
        headers["Authorization"] = f"Bearer {token}"
    return headers 

# Extrahiert die Questionnaire-ID aus verschiedenen Referenz-Formaten
def _questionnaire_id_from_ref(ref: str) -> str:
    if not ref:
        return ""
    ref = ref.split("|", 1)[0].strip()
    if "/Questionnaire/" in ref:
        return ref.split("/Questionnaire/", 1)[1].split("/", 1)[0]
    if ref.startswith("Questionnaire/"):
        return ref.split("/", 1)[1]
    return ref

# Extrahiert die Practitioner-ID aus einer FHIR-Referenz
def _practitioner_id_from_reference(ref: str) -> str:
    if not ref:
        return ""
    if "/Practitioner/" in ref:
        return ref.split("/Practitioner/", 1)[1].split("/", 1)[0]
    if ref.startswith("Practitioner/"):
        return ref.split("/", 1)[1]
    return ""

# Patients

def fetch_patients(count=25, search=None, practitioner_id=None):
    base = settings.FHIR_BASE_URL.rstrip("/") # Basis-URL des FHIR-Servers
    url = f"{base}/Patient"

    params = {"_count": count} # Maximale Anzahl zurückgegebener Patienten
    if search:
        params["name"] = search 

# HTTP-GET Request an den FHIR-Server
    r = requests.get(
        url,
        headers=_headers(),
        params=params,
        timeout=getattr(settings, "FHIR_TIMEOUT", 10),
        verify=getattr(settings, "FHIR_VERIFY_SSL", True),)
    
    r.raise_for_status()
    bundle = r.json() # Antwort als JSON (FHIR Bundle)

    patients = [] # Ergebnis
    # Iteration über alle Bundle-Einträge
    for entry in bundle.get("entry", []):
        res = entry.get("resource", {})
        if res.get("resourceType") != "Patient": # Nur Patient-Ressourcen berücksichtigen
            continue

        # Arzt-Filter (generalPractitioner)
        if practitioner_id:
            gp_list = res.get("generalPractitioner", []) or []
            gp_ids = []
            for gp in gp_list: # Extrahieren aller Practitioner-IDs aus den Referenzen
                ref = gp.get("reference", "")
                gp_ids.append(_practitioner_id_from_reference(ref))

            if practitioner_id not in gp_ids: # Patient überspringen wenn Arzt nicht zugeordnet ist
                continue

        pid = res.get("id", "")
        name = pid
        names = res.get("name", [])  # Patientenname aus dem "name"-Array zusammensetzen
        if names:
            n = names[0]
            given = " ".join(n.get("given", []))
            family = n.get("family", "")
            name = (given + " " + family).strip() or pid

        patients.append({
            "id": pid,
            "name": name,
            "gender": res.get("gender", "-"),
            "birthDate": res.get("birthDate", "-"),
        })

    return patients # Liste der Patienten zurückgeben


def fhir_list_patients(count=25, search=None):
    return fetch_patients(count=count, search=search)


def fetch_patient_by_id(patient_id: str) -> dict:
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


# Questionnaires & Responses

# Lädt ein FHIR Questionnaire anhand seiner ID vom FHIR-Server und gibt die vollständige Questionnaire-Ressource als Dictionary zurück
def fetch_questionnaire_by_id(qid: str) -> dict:
    base = settings.FHIR_BASE_URL.rstrip("/")
    url = f"{base}/Questionnaire/{qid}"

    r = requests.get(
        url,
        headers=_headers(),
        timeout=getattr(settings, "FHIR_TIMEOUT", 10),
        verify=getattr(settings, "FHIR_VERIFY_SSL", True),
    )
    r.raise_for_status()
    return r.json()

# Mapping von linkId → Fragetext
def build_question_text_map(questionnaire: dict) -> dict:
    mapping = {}

    def walk(items):
        for it in items or []: # Durchlauf aller Items und Sub-Items
            link_id = it.get("linkId") # linkId identifiziert die Frage eindeutig
            text = it.get("text")
            if link_id and text:
                mapping[link_id] = text
            walk(it.get("item", []))

    walk(questionnaire.get("item", []))
    return mapping

# Ruft über einen FHIR-Suchlink alle QuestionnaireResponses eines Patienten ab 
def fetch_questionnaires_for_patient_from_link(link: str):
    r = requests.get(
        link,
        headers=_headers(),
        timeout=getattr(settings, "FHIR_TIMEOUT", 10),
        verify=getattr(settings, "FHIR_VERIFY_SSL", True),
    )
    r.raise_for_status()
    bundle = r.json()

    labels = getattr(settings, "QUESTIONNAIRE_LABELS", {})
    seen = set()
    out = []

    for entry in bundle.get("entry", []):
        qr = entry.get("resource", {})
        if qr.get("resourceType") != "QuestionnaireResponse": # Nur QuestionnaireResponse-Ressourcen berücksichtigen
            continue
        
        # Referenz auf das zugehörige Questionnaire
        qref = qr.get("questionnaire", "")
        qid = _questionnaire_id_from_ref(qref)
        if not qid or qid in seen:
            continue
        
        # Ergebnisobjekt aufbauen
        seen.add(qid)
        out.append({"id": qid, "label": labels.get(qid, qid), "response_id": qr.get("id", ""),})
    
    # Reiehnfolge des Questionnaire
    order = ["f1", "f2", "tachtsamkeit", "tsport", "ternaehrung", "twohlbefinden", "tschlaf"]
    out.sort(key=lambda x: order.index(x["id"]) if x["id"] in order else 999)
    return out

# Lädt eine konkrete QuestionnaireResponse anhand ihrer ID vom FHIR-Server und gibt sie vollständig als Dictionary zurück
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

# Score / Interpretation

def _extract_score_and_interpretation(qr: dict):
    score = None
    interpretation = None

    def parse_value(ans: dict):
        for k, v in ans.items():
            if k.startswith("value"):
                return v
        return None

    def walk(items):
        nonlocal score, interpretation
        for it in items or []:
            link_id = it.get("linkId", "")
            answers = it.get("answer", []) or []
            if answers:
                v = parse_value(answers[0])
                if link_id == "0.1" and score is None:
                    score = v
                if link_id == "0.2" and interpretation is None:
                    interpretation = v
            walk(it.get("item", []))

    walk(qr.get("item", []))
    return score, interpretation

# Antworten anzeigen

def answers_from_questionnaire_response(questionnaire_id: str, qr: dict):
    # Zugehöriges Questionnaire anhand der ID laden
    questionnaire = fetch_questionnaire_by_id(questionnaire_id)

    # Mapping von linkId → Fragetext aufbauen
    text_map = build_question_text_map(questionnaire)

    def parse_value(answer_obj: dict, question_text: str) -> str:
        # Durchlauft alle Felder im Answer-Objekt
        for k, v in answer_obj.items():
            if not k.startswith("value"):
                continue

            # Nicht-String-Werte direkt in String umwandeln
            if not isinstance(v, str):
                return str(v)

            if "Stunden haben Sie geschlafen" in question_text:
                v = re.sub(r"^\d(?=\s*\d)", "", v).lstrip()

            # Fügt ein Leerzeichen zwischen Zahl und Text ein 
            return re.sub(r"^(\d+)(\D+)", r"\1 \2", v)

        return ""

    results = []  # Ergebnisliste

    def walk_items(items):
        # Durchlauf aller QuestionnaireResponse-Items
        for it in items or []:
            link_id = it.get("linkId", "")
            question_text = it.get("text") or text_map.get(link_id) or link_id

            # Alle Antworten parsen und normalisieren
            answers = [
                parse_value(a, question_text)
                for a in (it.get("answer", []) or [])
            ]

            # Leere Antworten entfernen
            answers = [a for a in answers if a]

            # Nur Fragen mit Antworten ins Ergebnis aufnehmen
            if answers:
                results.append({
                    "linkId": link_id,        
                    "question": question_text,  
                    "answers": answers,      
                })

            walk_items(it.get("item", []))

    walk_items(qr.get("item", []))

    # Liste aller Fragen mit Antworten zurückgeben
    return results


# neuester Score

# Lädt alle QuestionnaireResponses eines Patienten über einen FHIR-Link und extrahiert Zusammenfassungen (Datum, Score, Interpretation)für ein bestimmtes Questionnaire
def fetch_questionnaire_response_summaries_for_patient(link: str, questionnaire_id: str):
    # HTTP-GET Request 
    r = requests.get(
        link,
        headers=_headers(),  
        timeout=getattr(settings, "FHIR_TIMEOUT", 10),       
        verify=getattr(settings, "FHIR_VERIFY_SSL", True),   
    )

    r.raise_for_status()
    bundle = r.json()

    out = []  # Ergebnisliste 

    # Iteration über alle Bundle-Einträge
    for entry in bundle.get("entry", []):
        qr = entry.get("resource", {})

        # Nur QuestionnaireResponse-Ressourcen berücksichtigen
        if qr.get("resourceType") != "QuestionnaireResponse":
            continue

        # Referenz auf das zugehörige Questionnaire
        qref = qr.get("questionnaire", "")
        qid = _questionnaire_id_from_ref(qref)

        # Nur Responses für das gewünschte Questionnaire
        if qid != questionnaire_id:
            continue

        # Score und Interpretation aus der QuestionnaireResponse extrahieren
        score, interpretation = _extract_score_and_interpretation(qr)

        out.append({
            "id": qr.get("id", ""),  # QuestionnaireResponse-ID
            # Erstellungsdatum auf letztes Update
            "authored": qr.get("authored")
                        or qr.get("meta", {}).get("lastUpdated")
                        or "",
            "score": score,                    #
            "interpretation": interpretation,  
        })

    # Sortieren nach Datum (neueste zuerst)
    out.sort(key=lambda x: x["authored"] or "", reverse=True)

    return out

# Liefert den neuesten Score eines bestimmten Questionnaires für einen gegebenen Patienten
def fetch_latest_score_for_patient(patient_id: str, questionnaire_id: str):
    qr_link = settings.FHIR_QR_LINK_TEMPLATE.format(id=patient_id)
    # Alle verfügbaren Summaries laden
    summaries = fetch_questionnaire_response_summaries_for_patient(qr_link,questionnaire_id)

    if not summaries:
        return "-"

    # Neuester Eintrag 
    latest = summaries[0]

    # Score auslesen
    score = latest.get("score")

    # Score als String zurückgeben
    return str(score) if score is not None else "-"
