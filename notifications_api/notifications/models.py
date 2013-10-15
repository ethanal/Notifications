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
    device_token = models.CharField(max_length=64)

    def __str__(self):
        return self.device_token

class Feed(models.Model):
    user = models.ForeignKey(User)
    name = models.CharField(max_length=50)
    pin = models.PositiveIntegerField()
    devices = models.ManyToManyField(Device)

    def __str__(self):
        return self.name

class Notification(models.Model):
    sent_date = models.DateTimeField(auto_now_add=True)
    viewed = models.BooleanField(default=False)

    feed = models.ForeignKey(Feed)

    message = models.CharField(max_length=256)
    long_message = models.TextField()

    # https://developer.apple.com/library/mac/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/ProvisioningDevelopment.html#//apple_ref/doc/uid/TP40008194-CH104-SW1
    def send(self, devices):
        cert = os.path.join(settings.PROJECT_ROOT, "Notifications.pem")
        apns_server = ("gateway.sandbox.push.apple.com", 2195)

        s = socket.socket()
        sock = ssl.wrap_socket(s, ssl_version=ssl.PROTOCOL_SSLv3, certfile=cert)
        sock.connect(apns_server)

        payload_dict = {
            "aps": {
                "alert" : self.message
            }
        }

        payload = json.dumps(payload_dict)
        print len(payload)
        tokens = [device.device_token for device in devices]

        for token in tokens:
            token = binascii.unhexlify(token)
            fmt = "!cH32sH{0:d}s".format(len(payload))
            cmd = '\x00'
            msg = struct.pack(fmt, cmd, len(token), token, len(payload), payload)
            sock.write(msg)

        sock.close()

    def __str__(self):
        return self.message


@receiver(models.signals.post_save, sender=User)
def create_auth_token(sender, instance=None, created=False, **kwargs):
    if created:
        Token.objects.create(user=instance)