from django.urls import path
from . import views

urlpatterns = [
    path("", views.startseite, name="startseite"),
    path("home/", views.home, name="home"),
    path("patients/<str:patient_id>/", views.patient_detail, name="patient_detail"),  
    # path("logout/", views.logout_view, name="logout"),
    path("patients/<str:patient_id>/questionnaires/<str:questionnaire_id>/",
    views.patient_questionnaire,
    name="patient_questionnaire",),
    path("patients/<str:patient_id>/questionnaires/<str:questionnaire_id>/responses/<str:response_id>/",
    views.patient_questionnaire_response_detail,
    name="patient_questionnaire_response_detail",),
    path("patients/<str:patient_id>/sensors/", views.patient_sensors, name="patient_sensors"),
    #path("login/", views.lanr_login, name="lanr_login"),
    #path("logout/", views.lanr_logout, name="lanr_logout"),
]