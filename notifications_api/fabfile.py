from fabric.api import cd, run, prefix, env


def deploy():
    env.forward_agent = True
    with cd("/usr/local/www/notifications"):
        run("git pull")
        with cd("notifications_api"):
            with prefix("source /usr/local/virtualenvs/notifications/bin/activate && export PRODUCTION=TRUE"):
                run("./manage.py migrate")
                run("./manage.py collectstatic --noinput")
            run("supervisorctl restart notifications")
