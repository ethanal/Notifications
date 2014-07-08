from random import randint
import threading
from django import forms
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User
from django.http import HttpResponseRedirect, HttpResponseNotFound, HttpResponseForbidden
from django.shortcuts import render
from django.utils.datastructures import MultiValueDictKeyError
from rest_framework import authentication, permissions, status
from rest_framework.authtoken.models import Token
from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.generics import UpdateAPIView
from rest_framework.response import Response
from rest_framework.views import APIView
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
            user = form.save()
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
    return render(request, "notifications/dashboard.html", {
        "user": request.user,
        "api_key": Token.objects.get(user=request.user.pk).key,
        "devices": Device.objects.filter(id__in=list(set([d for d in feedset.values_list("devices", flat=True) if d is not None]))),
        "feeds": feeds,
        "feed_form": form or FeedForm(),
        "form_errors": form_errors
    })


def logout_view(request):
    logout(request)
    return HttpResponseRedirect("/")


@login_required
def create_feed(request):
    if request.method == "POST":
        data = request.POST.copy()
        data["user"] = request.user.pk
        data["pin"] = randint(100000, 999999)
        form = FeedForm(data)
        if form.is_valid():
            form.save()
            return HttpResponseRedirect("/")
        else:
            return dashboard_view(request, form=form, form_errors=form.errors)
    else:
        return HttpResponseRedirect("/")


@login_required
def delete_feed(request, pk):
    if request.method == "POST":
        try:
            feed = Feed.objects.get(pk=pk)
            Notification.objects.filter(feed=feed).delete()
            feed.delete()
        except Feed.DoesNotExist:
            return HttpResponseNotFound("Feed does not exist.")
        return HttpResponseRedirect("/")
    else:
        return HttpResponseRedirect("/")


@api_view(["GET"])
@authentication_classes((authentication.TokenAuthentication,))
@permission_classes((permissions.IsAdminUser,))
def list_feeds(request):
    try:
        feeds = Device.objects.get(device_token=request.GET["device_token"]).feed_set.all()
    except MultiValueDictKeyError:
        print "hi"
        return Response({"error": "'device_token' parameter must be specified"}, status=status.HTTP_400_BAD_REQUEST)
    return Response(FeedSerializer(feeds, many=True).data)


@api_view(["POST"])
@authentication_classes((authentication.TokenAuthentication,))
@permission_classes((permissions.IsAdminUser,))
def subscribe_to_feed(request, feed):
    try:
        feed = Feed.objects.get(pk=feed)
        try:
            if int(request.DATA["pin"]) != feed.pin:
                return Response({"error": "Invalid PIN"}, status=status.HTTP_403_FORBIDDEN)
        except ValueError:
            return Response({"error": "Invalid PIN"}, status=status.HTTP_400_BAD_REQUEST)


        device, created = Device.objects.get_or_create(device_token=request.DATA["device_token"])
        feed.devices.add(device)
        return Response({"success": "Device successfully subscribed to feed"}, status=status.HTTP_201_CREATED)
    except Feed.DoesNotExist:
        return Response({"error": "Feed does not exist"}, status=status.HTTP_404_NOT_FOUND)
    except MultiValueDictKeyError:
        return Response({"error": "'device_token' and 'pin' header must be specified"}, status=status.HTTP_400_BAD_REQUEST)

@api_view(["POST"])
@authentication_classes((authentication.TokenAuthentication,))
@permission_classes((permissions.IsAdminUser,))
def unsubscribe_from_feed(request, feed):
    try:
        feed = Feed.objects.get(pk=feed)
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
@authentication_classes((authentication.TokenAuthentication,))
@permission_classes((permissions.IsAdminUser,))
def list_notifications(request):
    try:
        notifications = Notification.objects.filter(feed__pk=request.GET["feed"]).order_by("-sent_date")
    except KeyError:
        return Response({"error": "'feed' parameter must be specified"}, status=status.HTTP_400_BAD_REQUEST)
    return Response(NotificationSerializer(notifications, many=True).data)


@api_view(["POST"])
@authentication_classes((authentication.TokenAuthentication,))
@permission_classes((permissions.IsAdminUser,))
def set_viewed(request, pk, format=None):
    try:
        n = Notification.objects.get(pk=pk)
        n.viewed = True
        n.save()
        return Response({"success": "Notification marked as viewed"})
    except Notification.DoesNotExist:
        return Response({"error": "Notification does not exist"}, status=status.HTTP_404_NOT_FOUND)


@api_view(["POST"])
@authentication_classes((authentication.TokenAuthentication,))
@permission_classes((permissions.IsAuthenticated,))
def send_notification(request):
    try:
        feed = Feed.objects.get(pk=request.DATA["feed"])

        n = Notification.objects.create(feed=feed, message=request.DATA["message"], long_message=request.DATA.get("long_message", ""))
        t = threading.Thread(target=n.send,
                             args=[feed.devices.all()],
                             kwargs={})
        t.setDaemon(True)
        t.start()
        return Response({"success": "Notification successfully sent"})
    except Feed.DoesNotExist:
        return Response({"error": "Feed does not exist."}, status=status.HTTP_404_NOT_FOUND)
    except MultiValueDictKeyError:
        return Response({"error": "'feed' and 'message' headers must be specified"}, status=status.HTTP_400_BAD_REQUEST)


@api_view(["POST"])
@authentication_classes((authentication.TokenAuthentication,))
@permission_classes((permissions.IsAuthenticated,))
def send_notification(request):
    try:
        feed = Feed.objects.get(pk=request.DATA["feed"])

        n = Notification.objects.create(feed=feed, message=request.DATA["message"], long_message=request.DATA.get("long_message", ""))
        t = threading.Thread(target=n.send,
                             args=[feed.devices.all()],
                             kwargs={})
        t.setDaemon(True)
        t.start()
        return Response({"success": "Notification successfully sent"})
    except Feed.DoesNotExist:
        return Response({"error": "Feed does not exist."}, status=status.HTTP_404_NOT_FOUND)
    except MultiValueDictKeyError:
        return Response({"error": "'feed' and 'message' headers must be specified"}, status=status.HTTP_400_BAD_REQUEST)
