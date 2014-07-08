from django.forms import ModelForm
from .models import Feed


class FeedForm(ModelForm):
    class Meta:
        model = Feed
        fields = ["user", "pin", "name"]
