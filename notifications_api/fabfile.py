from fabric.api import cd, run


def deploy():
    with cd("/usr/local/www/notifications"):
        run("git pull")
        with cd("notifications_api"):
            run("source /usr/local/virtualenvs/notifications/bin/activate")
            run("./manage.py migrate")
            run("./manage.py collectstatic --noinput")
            run("sudo supervisorctl restart notifications")
