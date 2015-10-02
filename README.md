# docker-baseimage-django
Base image for Django projects.

## Usage

You can inherit from this base image for your Django project.

It supposes that the project is laid down with the following structure:

    ├── docker-compose.yml
    ├── .gitignore
    └── webapp                  # The django app
        ├── conf                # Settings go here
        │   ├── __init__.py     # Make it a module
        │   ├── base.py         # Base settings
        │   ├── development.py  # Development overrides
        │   ├── production.py   # Production specific stuff
        │   ├── urls.py         # Root urlconf
        │   └── wsgi.py         # WSGI app (for gunicorn)
        ├── Dockerfile
        ├── .dockerignore
        ├── entrypoint-pre.sh   # See entrypoint
        ├── requirements.txt    # App requirements
        └── src
            └── myproject       # The app(s) egg(s)


An example `Dockerfile` for a custom project might look like this:

    FROM abstracttechnology/django:latest
    MAINTAINER Foo Bar <foo.bar@example.com>

    COPY entrypoint-pre.sh entrypoint-pre.sh

    COPY requirements.txt requirements.txt
    COPY src/ src/

    USER root

    RUN chown -R webapp:webapp .

    USER webapp

    RUN virtualenv . && \
        ./bin/pip install --upgrade pip && \
        ./bin/pip install -r requirements.txt && \
        cd src/myproject && \
        ../../bin/python setup.py develop

    COPY conf/ conf/
    USER root
    RUN chown -R webapp:webapp .
    USER webapp

This will end up configuring a container with your app django app in it,
with an entrypoint that offers the following base commands:

* `run` to run the app with Gunicorn (4 sync workers)
* `manage` to launch `manage.py` commands
  (arguments are passed to the manage script)

These two commands are launched using `conf/production.py`
as settings module (which might extend from a common `conf/base.py` module).

There are other two commands that will instead run using `conf/development.py`,
`develop-run` and `develop-manage`.

If a command is not recognized,
it executed as-is (this allows you to launch other programs,
or a shell for debug).

If you need any extra steps to be executed any time the container starts,
before any command, add a `entrypoint-pre.sh` to the root
(as done in the example).

For example, if your postgres container is slow to boot up,
you can put in that file:

    source check_up.bash
    check_up "postgresql" ${POSTGRES_PORT_5432_TCP_ADDR} 5432

Supposing your container is called `postgres`,
if it's called `database` change `POSTGRES_PORT_5432_TCP_ADDR`
to `DATABASE_PORT_5432_TCP_ADDR`.

Similarly, if you want to handle extra "commands" in the entrypoint,
you can add a `entrypoint-extras.sh` file, with a construct like this:

    case $1 in
        foo)
            echo "Foo"
            ;;
        bar)
            echo "Bar"
            ;;
    esac

Remember to always make `.sh` files executable.

And that's all, happy Django-ing.
