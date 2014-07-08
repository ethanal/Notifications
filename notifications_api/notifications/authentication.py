from rest_framework import authentication, exceptions
from .models import UserToken


class MailgunAuthentication(authentication.BaseAuthentication):
    def authenticate(self, request):
        try:
            prefix, key, feed = request.POST.get("recipient", "").split("-")
        except ValueError:
            raise exceptions.AuthenticationFailed("Invalid email address format")

        try:
            user_token = UserToken.objects.get(key=key)
        except UserToken.DoesNotExist:
            raise exceptions.AuthenticationFailed("Invalid user token")

        return (user_token.user, None)
