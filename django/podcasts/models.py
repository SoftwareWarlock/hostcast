from __future__ import unicode_literals

from django.db import models
from django.conf import settings

class Podcast(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField()  # Should be in markdown
    owner = models.ForeignKey(settings.AUTH_USER_MODEL, related_name="podcasts")

class Episode(models.Model):
    title = models.CharField(max_length=255)
    file = models.FileField(upload_to='uploads/attachments/%Y/%m/%d', null=True)
    show_notes = models.TextField()  # Should be in markdown
    podcast = models.ForeignKey(Podcast, related_name="episodes")
