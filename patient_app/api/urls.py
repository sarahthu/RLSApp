from django.urls import path
from . import views

urlpatterns = [
    path("rls/questionnaire/", views.rls_questionnaire),
    path("rls/response/", views.rls_response),
]