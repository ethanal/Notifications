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
    url(r"^register$", "register_view", name="register"),
    url(r"^logout$", "logout_view", name="logout"),
    url(r"^createfeed$", "create_feed", name="create_feed"),
    url(r"^deletefeed/(\d+)$", "delete_feed", name="delete_feed"),
    url(r"^api/feeds/list$", "list_feeds", name="feedslist"),
    url(r"^api/feeds/(\d+)/subscribe", "subscribe_to_feed", name="subscribe_to_feed"),
    url(r"^api/feeds/(\d+)/unsubscribe", "unsubscribe_from_feed", name="unsubscribe_from_feed"),
    url(r"^api/notifications/list$", "list_notifications", name="list_notifications"),
    url(r"^api/notifications/(\d+)/viewed$", "set_viewed", name="set_viewed"),
    url(r"^api/notifications/send$", "send_notification", name="send_notification"),
    url(r"^api/notifications/mailgunsend$", "send_notification_from_mailgun", name="send_notification_from_mailgun"),
)
