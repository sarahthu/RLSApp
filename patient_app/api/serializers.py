from rest_framework import serializers
from django.contrib.auth import get_user_model
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

# Code für serializers.py wurde größtenteils von
# https://medium.com/@onurmaciit/mastering-jwt-authentication-in-django-rest-framework-best-practices-and-techniques-d47f906f530a
# übernommen, und so angpeasst dass für die Erstellung eines Users nur username und password (und keine Email) erforderlich sind

User = get_user_model()

# Serializer zum Erstellen eines neuen Benutzers. Nimmt username und passwort entgegen und erstellt ein neues User-Objekt mit verschlüsselt gespeichertem Passwort
class UserRegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['username', 'password']

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            password=validated_data['password']
        )
        return user


# Serializer für Erzeugung von JSON Web Tokens
class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token['username'] = user.username
        return token