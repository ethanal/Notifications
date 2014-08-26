import os
import binascii
import json
import socket
import ssl
import struct
from django.db import models
from django.dispatch import receiver
from django.contrib.auth.models import User
from rest_framework.authtoken.models import Token
from notifications_api import settings


class Device(models.Model):
    device_token = models.CharField(max_length=64, unique=True)
    user = models.ForeignKey(User)
    name = models.CharField(max_length=50)

    def __unicode__(self):
        return self.device_token


class Feed(models.Model):
    user = models.ForeignKey(User)
    name = models.CharField(max_length=50)
    devices = models.ManyToManyField(Device)

    def __unicode__(self):
        return self.name


class UserToken(models.Model):
    key = models.CharField(max_length=40, primary_key=True)
    user = models.OneToOneField(User, related_name="user_key")

    def save(self, *args, **kwargs):
        if not self.key:
            self.key = self.generate_key()
        return super(UserToken, self).save(*args, **kwargs)

    def generate_key(self):
        return binascii.hexlify(os.urandom(20)).decode()

    def __unicode__(self):
        return self.key


class Notification(models.Model):
    sent_date = models.DateTimeField(auto_now_add=True)
    viewed = models.BooleanField(default=False)

    feed = models.ForeignKey(Feed)

    title = models.CharField(max_length=256)
    message = models.TextField()

    # https://developer.apple.com/library/mac/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/ProvisioningDevelopment.html#//apple_ref/doc/uid/TP40008194-CH104-SW1
    def send(self, devices):
        cert = os.path.join(settings.PROJECT_ROOT, "Notifications.pem")
        apns_server = ("gateway.sandbox.push.apple.com", 2195)

        s = socket.socket()
        sock = ssl.wrap_socket(s, ssl_version=ssl.PROTOCOL_SSLv3, certfile=cert)
        sock.connect(apns_server)

        # 42 is length of the dict without the contents of the alert,
        # so (256-42) is the maximum length of the alert
        payload_dict = {
            "aps": {
                "alert": self.title[:(256-42)],
                "sound": "default"
            }
        }

        payload = json.dumps(payload_dict)

        device_tokens = [device.device_token for device in devices]
        print device_tokens
        for token in device_tokens:
            token = binascii.unhexlify(token)
            fmt = "!cH32sH{0:d}s".format(len(payload))
            cmd = '\x00'
            msg = struct.pack(fmt, cmd, len(token), token, len(payload), payload)
            sock.write(msg)

        sock.close()

    def __unicode__(self):
        return self.title


@receiver(models.signals.post_save, sender=User)
def create_tokens(sender, instance=None, created=False, **kwargs):
    if created:
        Token.objects.create(user=instance)
        UserToken.objects.create(user=instance)
