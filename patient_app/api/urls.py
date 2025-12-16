from django.urls import path
from .views import get_questionnaire, post_response

urlpatterns = [
    path("rls/questionnaire/<str:id>", get_questionnaire),
    path("rls/response/", post_response),
]