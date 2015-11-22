from rest_framework.permissions import IsAuthenticated
from rest_framework import viewsets

from models import Podcast, Episode
from serializers import PodcastSerializer, EpisodeSerializer

class PodcastViewSet(viewsets.ModelViewSet):
    queryset = Podcast.objects.all()
    serializer_class = PodcastSerializer

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)

    def get_queryset(self):
        return self.request.user.podcasts.all()

class EpisodeViewSet(viewsets.ModelViewSet):
    queryset = Episode.objects.all()
    serializer_class = EpisodeSerializer

    def get_queryset(self):
        return self.queryset.filter(podcast__owner=self.request.user)
