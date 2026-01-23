from django.contrib import admin
from django.contrib.auth import get_user_model

User = get_user_model()

@admin.register(User)
class ArztUserAdmin(admin.ModelAdmin):
    list_display = ("lanr", "full_name", "is_active", "is_staff")
    search_fields = ("lanr", "full_name")