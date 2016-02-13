from django.contrib.auth.models import AbstractBaseUser
from django.contrib.auth.models import BaseUserManager
from django.db import models


class UserManager(BaseUserManager):

    def create_user(self, email, password=None, **kwargs):
        if not email:
            raise ValueError('Users must have a valid email address.')

        user = self.model(email=self.normalize_email(email))
        user.set_password(password)
        user.save()

        return user

    def create_superuser(self, email, password, **kwargs):
        user = self.create_user(email, password, **kwargs)

        user.is_admin = True
        user.save()

        return user

    def get_by_natural_key(self, username):
        return self.get(**{self.model.USERNAME_FIELD + '__iexact': username})


class User(AbstractBaseUser):
    email = models.EmailField(unique=True)

    is_admin = models.BooleanField(default=False)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    objects = UserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

    def __unicode__(self):
        return self.email

    def __str__(self):
        return self.get_full_name() + " (" + self.email + ")"
