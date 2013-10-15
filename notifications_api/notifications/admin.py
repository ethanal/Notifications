from django.contrib import admin
from .models import Feed, Notification, Device


class FeedAdmin(admin.ModelAdmin):
    list_display = ["id", "user", "name", "pin"]

admin.site.register(Feed, FeedAdmin)


class NotificationAdmin(admin.ModelAdmin):
    list_display = ["id", "sent_date", "viewed", "feed", "message", "long_message"]

admin.site.register(Notification, NotificationAdmin)


class DeviceAdmin(admin.ModelAdmin):
    list_display = ["id", "device_token"]

admin.site.register(Device, DeviceAdmin)