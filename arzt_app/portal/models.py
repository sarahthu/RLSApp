
# Create your models here.
from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin, BaseUserManager

class ArztUserManager(BaseUserManager):
    def create_user(self, lanr, password=None, **extra_fields):
        if not lanr:
            raise ValueError("LANR ist erforderlich")
        user = self.model(lanr=str(lanr).strip(), **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, lanr, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        extra_fields.setdefault("is_active", True)
        return self.create_user(lanr, password, **extra_fields)

class ArztUser(AbstractBaseUser, PermissionsMixin):
    lanr = models.CharField(max_length=20, unique=True)
    full_name = models.CharField(max_length=200, blank=True)

    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    objects = ArztUserManager()

    USERNAME_FIELD = "lanr"

    def __str__(self):
        return self.lanr
