from .models import Feed, Notification
from rest_framework import serializers


class FeedSerializer(serializers.ModelSerializer):
    has_unread = serializers.SerializerMethodField("check_unread")

    def check_unread(self, feed):
        return Notification.objects.filter(feed=feed, viewed=False).count() != 0

    class Meta:
        model = Feed
        fields = ("id", "name", "has_unread")


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ("id", "sent_date", "viewed", "feed", "message", "long_message")