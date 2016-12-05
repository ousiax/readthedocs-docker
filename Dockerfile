FROM debian
MAINTAINER qqbuby <qqbuby@gmail.com>

RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak
COPY ./datas/sources.list.jessie /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
    build-essential \
    python-dev \
    python-pip \
    python-setuptools \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    git \
    && apt-get autoremove

RUN curl -fsS https://bootstrap.pypa.io/get-pip.py | python && pip install virtualenv

# Read the docs
# Create a virtual environment, then active it
RUN mkdir -p /var/readthedocs
RUN virtualenv /var/readthedocs
RUN source /var/readthedocs/bin/active

# Creat a folder here, and clone the repository
RUN mkdir /var/readthedocs/checkouts
WORKDIR /var/readthedocs/checkouts

RUN git clone http://gitlab.gridsum.com/xuqiang/readthedocs.git
WORKDIR /var/readthedocs/checkouts/readthedocs

# Install the depedencies using pip (included inside of virtualenv)
RUN pip install -r requirements.txt

# This may take a while, so go grab a beverage. When it's done, build your database:
RUN python manage.py migrate

# Then please create a super account for Django,
# and create an account for API use and set SLUMBER_USERNAME and SLUMBER_PASSWORD in order for everything to work properly.
RUN python -c "import os;import sys;os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'readthedocs.settings.dev');sys.path.append(os.getcwd());from django.contrib.auth.models import User;admin = User.objects.create_user('admin','','admin');admin.is_superuser=True;admin.is_staff=True;admin.save();test = User.objects.create_user('test','','test');test.is_staff=True;test.save();"

# Now let's properly generate the static assets:
RUN python manage.py collectstatic --noinput

# Finally, you're ready to start the webserver: python manage.py runserver

# Configuration of the production servers
# Create and put a file named local_settings.py in the readthedocs/settings directory, it will override settings available in the base install.
COPY ./datas/local_settings ./readthedocs/settings

# Install uWSGI with Python support
# To build with pcre support, please install pcre lib with apt-get install -y libpcre3-dev
RUN apt-get install -y libpcre3-dev && pip install uwsgi && apt-get autoremove

# Configuration file readthedocs.ini in /var/readthedocs/checkouts/readthedocs/
COPY ./datas/readthedocs.ini .

# Create an account used by the readthedocs
RUN useradd -M -s /sbin/nologin -c"Account used by the readthedocs" readthedocs

# change the owner of /var/readthedocs to readthedocs
RUN chown -R readthedocs:readthedocs /var/readthedocs/

# By default, uWSGI uses the [uwsgi] section, but you can specify another section name while loading the INI file with the syntax filename:section, that is [uwsgi-docs]
CMD uwsgi --ini readthedocs.ini:dev
