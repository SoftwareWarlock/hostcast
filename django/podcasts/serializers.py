from rest_framework import serializers

from models import Podcast, Episode

class EpisodeSerializer(serializers.ModelSerializer):

    class Meta:
        model = Episode

class PodcastSerializer(serializers.ModelSerializer):

    class Meta:
        model = Podcast
        exclude = ("owner",)
