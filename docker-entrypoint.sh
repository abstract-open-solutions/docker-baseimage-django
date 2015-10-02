#!/bin/bash
set -e

if [ -f ./entrypoint-pre.sh ]; then
    ./entrypoint-pre.sh
fi

args=("$@")

case $1 in
    manage)
        export DJANGO_SETTINGS_MODULE=conf.production
        bin/python manage.py ${args[@]:1}
        ;;
    run)
        export DJANGO_SETTINGS_MODULE=conf.production
        bin/gunicorn conf.wsgi -b 0.0.0.0:8000 -w 4
        ;;
    develop-manage)
        export DJANGO_SETTINGS_MODULE=conf.development
        bin/python manage.py ${args[@]:1}
        ;;
    develop-run)
        export DJANGO_SETTINGS_MODULE=conf.development
        bin/python manage.py runserver 0.0.0.0:8000
        ;;
    *)
        if [ -f ./entrypoint-extras.sh ]; then
            ./entrypoint-extras.sh
        else
            exec "$@"
        fi
        ;;
esac
