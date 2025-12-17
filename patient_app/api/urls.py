from django.urls import path
from .views import get_questionnaire, post_response, get_questionnaire_response

urlpatterns = [
    path("rls/questionnaire/<str:id>", get_questionnaire),
    path("rls/getresponse/<str:date>", get_questionnaire_response),
    path("rls/response/", post_response),
]