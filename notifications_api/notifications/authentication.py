from django.utils.datastructures import MultiValueDictKeyError
from rest_framework import authentication, exceptions
from .models import UserToken


class MailgunAuthentication(authentication.BaseAuthentication):
    def authenticate(self, request):
        try:
            prefix, key, feed = request.POST.get("recipient").split("_")
        except (ValueError, IndexError, MultiValueDictKeyError):
            raise exceptions.NotAcceptable("Invalid email address format")

        try:
            user_token = UserToken.objects.get(key=key)
        except UserToken.DoesNotExist:
            raise exceptions.NotAcceptable("Invalid user token")

        return (user_token.user, None)
