from django.contrib import admin
from .models import Device, Feed, UserToken, Notification


class DeviceAdmin(admin.ModelAdmin):
    list_display = ("device_token", "user")

admin.site.register(Device, DeviceAdmin)


class FeedAdmin(admin.ModelAdmin):
    list_display = ("id", "user", "name")

admin.site.register(Feed, FeedAdmin)


class UserTokenAdmin(admin.ModelAdmin):
    list_display = ("key", "user")
    fields = ("user",)

admin.site.register(UserToken, UserTokenAdmin)


class NotificationAdmin(admin.ModelAdmin):
    list_display = ("id",
                    "sent_date",
                    "viewed",
                    "feed",
                    "title",
                    "message")

admin.site.register(Notification, NotificationAdmin)
