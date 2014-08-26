import base64
import threading
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User
from django.core.urlresolvers import reverse
from django.http import HttpResponseRedirect, HttpResponseNotFound
from django.shortcuts import render
from django.utils.datastructures import MultiValueDictKeyError
from rest_framework import status
from rest_framework.decorators import api_view, authentication_classes
from rest_framework.response import Response
from .authentication import MailgunAuthentication
from .models import Feed, Notification, Device
from .forms import FeedForm
from .serializers import FeedSerializer, NotificationSerializer


def login_view(request):
    if request.method == "POST":
        user = authenticate(username=request.POST["username"], password=request.POST["password"])
        if user is not None:
            if user.is_active:
                login(request, user)
                return HttpResponseRedirect("/")
            else:
                return render(request, "notifications/login.html", {"message": "Your account has been disabled."})
        else:
            return render(request, "notifications/login.html", {"message": "Username and password did not match."})

    else:
        return render(request, "notifications/login.html", {})


def register_view(request):
    context = {}
    if request.method == "POST":
        form = UserCreationForm(request.POST)
        if form.is_valid():
            form.save()
            return render(request, "notifications/login.html", {"message": "Your account has been created."})
        else:
            context["message"] = "Form invalid"
    else:
        form = UserCreationForm()
    return render(request, "notifications/register.html", context)


@login_required(redirect_field_name=None)
def dashboard_view(request, form=None, form_errors=False):
    feedset = User.objects.get(pk=request.user.pk).feed_set
    feeds = feedset.all()
    for key, feed in enumerate(feeds):
        feeds[key].notification_count = Notification.objects.filter(feed=feed).count()

    api_root_uri = request.build_absolute_uri(reverse("api_root"))
    qr_code_contents = base64.b64encode("{} {}".format(api_root_uri, request.user.auth_token.key))
    qr_code_url = "http://chart.apis.google.com/chart?cht=qr&chs=300x300&chld=H|0&chl=" + qr_code_contents
    return render(request, "notifications/dashboard.html", {
        "user": request.user,
        "devices": Device.objects.filter(id__in=list(set([d for d in feedset.values_list("devices", flat=True) if d is not None]))),
        "feeds": feeds,
        "feed_form": form or FeedForm(),
        "form_errors": form_errors,
        "qr_code_url": qr_code_url
    })


def logout_view(request):
    logout(request)
    return HttpResponseRedirect("/")


@api_view(["GET"])
def api_root(request):
    """Welcome to the Notifications API!

    Documentation can be found at [github.com/ethanal/Notifications](https://github.com/ethanal/Notifications)
    """

    return Response("Documentation can be found at github.com/ethanal/Notifications")


@api_view(["GET"])
def device_info(request, device_token):
    try:
        return Response({
            "username": request.user.username,
            "device_name": Device.objects.filter(user=request.user).get(device_token=device_token).name
        })
    except Device.DoesNotExist:
        return Response({"error": "Device does not exist."}, status=status.HTTP_404_NOT_FOUND)


@login_required
def create_feed(request):
    if request.method == "POST":
        data = request.POST.copy()
        data["user"] = request.user.pk
        form = FeedForm(data)
        if form.is_valid():
            form.save()
            return HttpResponseRedirect("/")
        else:
            return dashboard_view(request, form=form, form_errors=form.errors)
    else:
        return HttpResponseRedirect("/")


@login_required
def delete_feed(request, feed):
    if request.method == "POST":
        try:
            feed = Feed.objects.get(pk=feed)
            Notification.objects.filter(feed=feed).delete()
            feed.delete()
        except Feed.DoesNotExist:
            return HttpResponseNotFound("Feed does not exist.")
        return HttpResponseRedirect("/")
    else:
        return HttpResponseRedirect("/")


@api_view(["GET"])
def list_feeds(request):
    feeds = Feed.objects.filter(user=request.user)
    if "device_token" in request.GET:
        feeds = feeds.filter(devices__device_token=request.GET["device_token"])

    return Response(FeedSerializer(feeds, many=True).data)


@api_view(["GET"])
def list_unsubscribed_feeds(request):
    feeds = Feed.objects.filter(user=request.user)
    if "device_token" not in request.GET:
        return Response({"error": "'device_token' parameter must be specified"}, status=status.HTTP_400_BAD_REQUEST)
    feeds = feeds.exclude(devices__device_token=request.GET["device_token"])

    return Response(FeedSerializer(feeds, many=True).data)


@api_view(["POST"])
def subscribe_to_feed(request, feed):
    try:
        feed = Feed.objects.get(pk=feed, user=request.user)
        device = Device.objects.get(device_token=request.DATA["device_token"], user=request.user)
        feed.devices.add(device)
        return Response({"success": "Device successfully subscribed to feed"}, status=status.HTTP_201_CREATED)
    except Feed.DoesNotExist:
        return Response({"error": "Feed does not exist"}, status=status.HTTP_404_NOT_FOUND)
    except Device.DoesNotExist:
        return Response({"error": "Device with specified 'device_token' does not exist"}, status=status.HTTP_404_NOT_FOUND)
    except MultiValueDictKeyError:
        return Response({"error": "'device_token' field must be specified"}, status=status.HTTP_400_BAD_REQUEST)


@api_view(["POST"])
def register_device(request):
    print request.DATA
    try:
        Device.objects.filter(device_token=request.DATA["device_token"]).delete()
        Device.objects.create(device_token=request.DATA["device_token"],
                              name=request.DATA["name"][:50],
                              user=request.user)

        return Response({"success": "Device successfully registered"}, status=status.HTTP_201_CREATED)
    except Device.DoesNotExist:
        return Response({"error": "Device with specified 'device_token' does not exist"}, status=status.HTTP_404_NOT_FOUND)
    except MultiValueDictKeyError:
        return Response({"error": "'device_token' and 'name' fields must be specified"}, status=status.HTTP_400_BAD_REQUEST)


@api_view(["POST"])
def unsubscribe_from_feed(request, feed):
    try:
        feed = Feed.objects.get(pk=feed, user=request.user)
        device = Device.objects.get(device_token=request.DATA["device_token"])

        feed.devices.remove(device)
        return Response({"success": "Device successfully unsubscribed from feed"}, status=status.HTTP_200_OK)
    except Feed.DoesNotExist:
        return Response({"error": "Feed does not exist."}, status=status.HTTP_404_NOT_FOUND)
    except Device.DoesNotExist:
        return Response({"error": "Device does not exist."}, status=status.HTTP_404_NOT_FOUND)
    except MultiValueDictKeyError:
        return Response({"error": "'device_token' header must be specified"}, status=status.HTTP_400_BAD_REQUEST)


@api_view(["GET"])
def list_notifications(request, feed):
    try:
        feed = Feed.objects.get(pk=feed, user=request.user)
    except Feed.DoesNotExist:
        return Response({"error": "Feed does not exist."}, status=status.HTTP_404_NOT_FOUND)

    try:
        notifications = Notification.objects.filter(feed=feed).order_by("-sent_date")
    except KeyError:
        return Response({"error": "'feed' parameter must be specified"}, status=status.HTTP_400_BAD_REQUEST)

    return Response(NotificationSerializer(notifications, many=True).data)


@api_view(["GET"])
def get_notification(request, pk):
    try:
        notification = Notification.objects.get(pk=pk, feed__user=request.user)
    except Notification.DoesNotExist:
        return Response({"error": "Notification does not exist."}, status=status.HTTP_404_NOT_FOUND)

    return Response(NotificationSerializer(notification).data)


@api_view(["POST"])
def mark_viewed(request, pk):
    try:
        n = Notification.objects.get(pk=pk, feed__user=request.user)
        n.viewed = True
        n.save()
        return Response({"success": "Notification marked as viewed"})
    except Notification.DoesNotExist:
        return Response({"error": "Notification does not exist"}, status=status.HTTP_404_NOT_FOUND)


@api_view(["POST"])
def mark_all_viewed(request, feed):
    try:
        feed = Feed.objects.get(pk=feed, user=request.user)
        feed.notification_set.update(viewed=True)
        return Response({"success": "All notifications in feed marked as viewed"})
    except Feed.DoesNotExist:
        return Response({"error": "Feed does not exist"}, status=status.HTTP_404_NOT_FOUND)


@api_view(["POST"])
def send_notification(request):
    try:
        data = {
            "feed": request.DATA.get("feed", None),
            "title": request.DATA.get("title", None),
            "message": request.DATA.get("message", None)
        }

        serializer = NotificationSerializer(data=data)
        if not serializer.is_valid():
            return Response({"error": "All fields are required", "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)

        feed = Feed.objects.get(pk=request.DATA["feed"], user=request.user)

        n = Notification.objects.create(feed=feed, title=request.DATA["title"], message=request.DATA["message"])
        t = threading.Thread(target=n.send,
                             args=[feed.devices.all()],
                             kwargs={})
        t.setDaemon(True)
        t.start()
        return Response({"success": "Notification successfully sent"})
    except Feed.DoesNotExist:
        return Response({"error": "Feed does not exist."}, status=status.HTTP_404_NOT_FOUND)


# @api_view(["POST"])
# @authentication_classes((MailgunAuthentication,))
# def send_notification_from_mailgun(request):
#     return Response({"success": "Sent notification from email."})
#     # try:
#     #     feed = Feed.objects.get(pk=request.DATA["feed"])

#     #     n = Notification.objects.create(feed=feed, message=request.DATA["message"], long_message=request.DATA.get("long_message", ""))
#     #     t = threading.Thread(target=n.send,
#     #                          args=[feed.devices.all()],
#     #                          kwargs={})
#     #     t.setDaemon(True)
#     #     t.start()
#     #     return Response({"success": "Notification successfully sent"})
#     # except Feed.DoesNotExist:
#     #     return Response({"error": "Feed does not exist."}, status=status.HTTP_404_NOT_FOUND)
#     # except MultiValueDictKeyError:
#     #     return Response({"error": "'feed' and 'message' headers must be specified"}, status=status.HTTP_400_BAD_REQUEST)
