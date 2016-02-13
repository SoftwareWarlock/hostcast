from django.conf.urls import url, include
from django.conf import settings
from django.contrib import admin
from django.conf.urls.static import static
from django.views.generic import TemplateView

from rest_framework.routers import DefaultRouter

from podcasts.views import PodcastViewSet, EpisodeViewSet

router = DefaultRouter()
router.register(r'podcasts', PodcastViewSet)
router.register(r'episodes', EpisodeViewSet)

urlpatterns = [
    url(r'^admin/', admin.site.urls),
    url(r'^auth/', include('djoser.urls.authtoken')),
    url(r'^app/*', TemplateView.as_view(template_name='index.html')),
    url(r'^api/', include(router.urls)),
] + static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
