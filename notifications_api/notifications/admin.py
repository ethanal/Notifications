from django.contrib import admin
from rest_framework.authtoken.admin import TokenAdmin
from .models import Device, Feed, UserToken, Notification


class DeviceAdmin(admin.ModelAdmin):
    list_display = ["device_token", "user", "feed_set"]

admin.site.register(Device, DeviceAdmin)


class FeedAdmin(admin.ModelAdmin):
    list_display = ["id",
                    "user",
                    "name"]

admin.site.register(Feed, FeedAdmin)


class UserTokenAdmin(TokenAdmin):
    pass

admin.site.register(UserToken, UserTokenAdmin)


class NotificationAdmin(admin.ModelAdmin):
    list_display = ["id",
                    "sent_date",
                    "viewed",
                    "feed",
                    "message",
                    "long_message"]

admin.site.register(Notification, NotificationAdmin)
