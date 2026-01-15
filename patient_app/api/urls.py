from django.urls import path
from .views import get_questionnaire, get_tagebuch_response, post_response, get_questionnaire_response, post_patient
from .views import RegisterView, CustomTokenObtainPairView
from rest_framework_simplejwt.views import TokenRefreshView

urlpatterns = [
    path("rls/questionnaire/<str:id>", get_questionnaire),
    path("rls/getresponse/<str:date>", get_questionnaire_response),
    path("rls/gettagebuchresponse/<str:date>", get_tagebuch_response),
    path("rls/response/", post_response),
    path("rls/patient/", post_patient),
    path('register/', RegisterView.as_view(), name='register'),
    path('token/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]