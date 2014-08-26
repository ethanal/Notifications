from django.conf.urls import patterns, include, url
from django.contrib import admin


admin.autodiscover()

urlpatterns = patterns(
    "",
    # Examples:
    # url(r"^$", "notifications_api.views.home", name="home"),
    # url(r"^notifications_api/", include("notifications_api.foo.urls")),

    # Uncomment the admin/doc line below to enable admin documentation:
    # url(r"^admin/doc/", include("django.contrib.admindocs.urls")),

    url(r"^admin/", include(admin.site.urls)),
    url(r"^api-auth/", include("rest_framework.urls", namespace="rest_framework")),
)


urlpatterns += patterns(
    "notifications.views",
    url(r"^$", "dashboard_view", name="dashboard"),
    url(r"^login$", "login_view", name="login"),
    url(r"^logout$", "logout_view", name="logout"),
    #url(r"^register$", "register_view", name="register"),
    url(r"^api$", "api_root", name="api_root"),
    url(r"^api/register_device$", "register_device", name="register_device"),
    url(r"^api/device_info/(?P<device_token>\w+)$", "device_info", name="device_info"),
    url(r"^api/feeds/list$", "list_feeds", name="list_feeds"),
    url(r"^api/feeds/list_unsubscribed$", "list_unsubscribed_feeds", name="list_unsubscribed_feeds"),
    url(r"^api/feeds/create$", "create_feed", name="create_feed"),
    url(r"^api/feeds/(?P<feed>\d+)/delete$", "delete_feed", name="delete_feed"),
    url(r"^api/feeds/(?P<feed>\d+)/subscribe", "subscribe_to_feed", name="subscribe_to_feed"),
    url(r"^api/feeds/(?P<feed>\d+)/unsubscribe", "unsubscribe_from_feed", name="unsubscribe_from_feed"),
    url(r"^api/feeds/(?P<feed>\d+)/notifications/list$", "list_notifications", name="list_notifications"),
    url(r"^api/feeds/(?P<feed>\d+)/notifications/mark_viewed", "mark_all_viewed", name="mark_all_viewed"),
    url(r"^api/notifications/(?P<pk>\d+)$", "get_notification", name="get_notification"),
    url(r"^api/notifications/(?P<pk>\d+)/mark_viewed$", "mark_viewed", name="mark_viewed"),
    url(r"^api/notifications/send$", "send_notification", name="send_notification"),
    url(r"^api/notifications/mailgun_send$", "send_notification_from_mailgun", name="send_notification_from_mailgun"),
)
