from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from requests import RequestException
from doctors.fhir_client import fetch_patients
from django.conf import settings
from doctors.fhir_client import fetch_questionnaires_for_patient_from_link
from doctors.fhir_client import fetch_questionnaire_answers_for_patient
from django.conf import settings
from doctors.fhir_client import (fetch_questionnaire_response_by_id,answers_from_questionnaire_response,fetch_questionnaire_response_summaries_for_patient)
from doctors.fhir_client import fetch_latest_score_for_patient
from django.contrib.auth.decorators import login_required


def startseite(request):
    error = None

    if request.method == "POST":
        lanr = request.POST.get("lanr", "").strip()
        password = request.POST.get("password", "")

        user = authenticate(request, lanr=lanr, password=password)
        if user is not None:
            login(request, user)
            return redirect("/home/")
        else:
            error = "LANR oder Passwort ist falsch."

    return render(request, "portal/startseite.html", {"error": error})

def _to_int_or_none(x):
    try:
        return int(str(x).strip())
    except Exception:
        return None


@login_required
def home(request):
    q = (request.GET.get("q") or "").strip()
    error = None

    # Ampel-Funktionen 
    def color_irls(v):
        """
        IRLS: 0-40, höher = schlechter
        Grün: 0-20, Orange: 21-30, Rot: 31-40
        """
        try:
            v = int(v)
        except Exception:
            return "#9ca3af"  # grau

        if v >= 31:
            return "#dc2626"  # rot
        if v >= 21:
            return "#f59e0b"  # orange
        return "#16a34a"      # grün

    def color_qol(v):
        try:
            v = int(v)
        except Exception:
            return "#9ca3af"  # grau

        if v <= 33:
            return "#dc2626"  # rot
        if v <= 66:
            return "#f59e0b"  # orange
        return "#16a34a"      # grün

    def priority_from_colors(c1, c2):
        colors = {c1, c2}

        if "#dc2626" in colors:
            return ("Hohe Priorität", "#dc2626")
        if "#f59e0b" in colors:
            return ("Mittlere Priorität", "#f59e0b")
        if "#16a34a" in colors:            
          return ("Niedrige Priorität", "#16a34a")
        return ("-", "#9ca3af")

    try:
        patients = fetch_patients(count=25, search=q if q else None)

        # Patient 12892 ausblenden
        patients = [p for p in patients if p.get("id") != "12892"]

        # Scores + Farben + Priorität pro Patient
        for p in patients:
            # f1
            try:
                p["score_f1"] = fetch_latest_score_for_patient(p["id"], "f1")
            except Exception:
                p["score_f1"] = "-"

            # f2
            try:
                p["score_f2"] = fetch_latest_score_for_patient(p["id"], "f2")
            except Exception:
                p["score_f2"] = "-"

            # Farben
            p["score_f1_color"] = color_irls(p.get("score_f1"))
            p["score_f2_color"] = color_qol(p.get("score_f2"))

            # Priorität
            label, col = priority_from_colors(p["score_f1_color"], p["score_f2_color"])
            p["priority_label"] = label
            p["priority_color"] = col

    except RequestException as ex:
        patients = []
        error = f"FHIR-Fehler: {ex}"

    return render(request, "portal/home.html", {
        "patients": patients,
        "q": q,
        "error": error,
    })


def logout_view(request):
    logout(request)
    return redirect("/")


@login_required
def patient_detail(request, patient_id):
    error = None
    questionnaires = []
    patient = None

    try:
        # Patientenliste erneut laden
        patients = fetch_patients(count=100)

        # gewünschten Patienten finden
        patient = next((p for p in patients if p["id"] == patient_id), None)
        if not patient:
            raise Exception("Patient nicht gefunden")

        # Fragebögen laden
        qr_link = settings.FHIR_QR_LINK_TEMPLATE.format(id=patient_id)
        questionnaires = fetch_questionnaires_for_patient_from_link(qr_link)

    except Exception as ex:
        error = f"FHIR-Fehler: {ex}"

    return render(request, "portal/patient_detail.html", {
        "patient": patient,
        "questionnaires": questionnaires,
        "error": error,
    })


@login_required
def patient_questionnaire(request, patient_id, questionnaire_id):
    error = None
    answers = []

    try:
        qr_link = settings.FHIR_QR_LINK_TEMPLATE.format(id=patient_id)
        answers = fetch_questionnaire_answers_for_patient(qr_link, questionnaire_id)
    except Exception as ex:
        error = f"FHIR-Fehler: {ex}"

    label = getattr(settings, "QUESTIONNAIRE_LABELS", {}).get(questionnaire_id, questionnaire_id)

    return render(request, "portal/patient_questionnaire.html", {
        "patient_id": patient_id,
        "questionnaire_id": questionnaire_id,
        "questionnaire_label": label,
        "answers": answers,
        "error": error,
    })


@login_required
def patient_questionnaire(request, patient_id, questionnaire_id):
    error = None
    summaries = []

    try:
        qr_link = settings.FHIR_QR_LINK_TEMPLATE.format(id=patient_id)
        summaries = fetch_questionnaire_response_summaries_for_patient(
            qr_link,
            questionnaire_id
        )
    except Exception as ex:
        error = f"FHIR-Fehler: {ex}"

    # Labels für Anzeige
    labels = getattr(settings, "QUESTIONNAIRE_LABELS", {})
    questionnaire_label = labels.get(questionnaire_id, questionnaire_id)

    chart_labels = []   # x-Achse (Datum)
    chart_scores = []   # y-Achse (Score)

    for s in summaries:
        if s.get("score") is None:
            continue

        # Datum aus authored 
        authored = s.get("authored", "")
        if authored:
            chart_labels.append(authored[:10])
            chart_scores.append(int(s["score"]))

    return render(request, "portal/patient_questionnaire_history.html", {
        "patient_id": patient_id,
        "questionnaire_id": questionnaire_id,
        "questionnaire_label": questionnaire_label,
        "summaries": summaries,
        "chart_labels": chart_labels,
        "chart_scores": chart_scores,
        "error": error,
    })


@login_required
def patient_questionnaire_response_detail(request, patient_id, questionnaire_id, response_id):
    error = None
    answers = []
    authored = ""

    try:
        qr = fetch_questionnaire_response_by_id(response_id)
        authored = qr.get("authored") or qr.get("meta", {}).get("lastUpdated") or ""
        answers = answers_from_questionnaire_response(questionnaire_id, qr)
    except Exception as ex:
        error = f"FHIR-Fehler: {ex}"

    labels = getattr(settings, "QUESTIONNAIRE_LABELS", {})
    questionnaire_label = labels.get(questionnaire_id, questionnaire_id)

    return render(request, "portal/patient_questionnaire_response_detail.html", {
        "patient_id": patient_id,
        "questionnaire_id": questionnaire_id,
        "questionnaire_label": questionnaire_label,
        "response_id": response_id,
        "authored": authored,
        "answers": answers,
        "error": error,
    })


@login_required
def patient_sensors(request, patient_id):
    # leer
    return render(request, "portal/patient_sensors.html", {
        "patient_id": patient_id,
    })
