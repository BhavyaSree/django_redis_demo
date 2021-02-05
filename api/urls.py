from django.urls import path
from rest_framework.urlpatterns import format_suffix_patterns
from .views import send_number

urlpatterns = {
    path('', send_number, name="items"),
}
urlpatterns = format_suffix_patterns(urlpatterns)