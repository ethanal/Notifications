from django.contrib.auth.models import User
from rest_framework import authentication, exceptions
from rest_framework.authtoken.models import Token


class MailgunAuthentication(authentication.BaseAuthentication):
    def authenticate(self, request):
        try:
            key = request.POST.get("recipient", "").split("-")[1]
        except:
            raise exception.AuthenticationFailed("Invalid email address")
        
        try:
            auth_token = Token.objects.get(key=key)
        except Token.DoesNotExist:
            raise exceptions.AuthenticationFailed("Invalid authentication token")

        return (user, None)
