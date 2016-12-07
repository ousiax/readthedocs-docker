FROM debian:jessie
MAINTAINER qqbuby <qqbuby@gmail.com>

ENV RTD_COMMIT ed4f90e4

ENV PYTHON_PIP_VERSION 9.0.1
ENV PIP_DEFAULT_TIMEOUT 60
# ENV PIP_INDEX_URL https://mirrors.ustc.edu.cn/pypi/web/simple

# RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak \
#     && echo 'deb http://mirrors.163.com/debian stable main contrib non-free' > /etc/apt/sources.list

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    python-dev \
    python-pip \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    git \
    && DEBIAN_FRONTEND=noninteractive apt-get -y autoremove

RUN pip install --upgrade --force-reinstall "pip==$PYTHON_PIP_VERSION" \
    && rm -rf ~/.cache

RUN pip --no-cache-dir install virtualenv

# Read the docs
# Create a virtual environment, then active it
RUN mkdir /var/readthedocs \
    && virtualenv /var/readthedocs/
# source /var/readthedocs/bin/activate

# Creat a folder here, and clone the repository
RUN mkdir /var/readthedocs/checkouts
WORKDIR /var/readthedocs/checkouts

RUN git clone https://github.com/rtfd/readthedocs.org.git readthedocs
WORKDIR /var/readthedocs/checkouts/readthedocs
RUN git reset ${RTD_COMMIT} --hard

# Install the depedencies using pip (included inside of virtualenv)
RUN . /var/readthedocs/bin/activate \
    && pip install --no-cache-dir -r requirements.txt

RUN . /var/readthedocs/bin/activate \
    && pip install --upgrade "pip==$PYTHON_PIP_VERSION" \
    && rm -rf ~/.cache

# This may take a while, so go grab a beverage. When it's done, build your database.
RUN . /var/readthedocs/bin/activate \
    && python ./manage.py migrate

# Then please create a super account for Django,
# and create an account for API use and set SLUMBER_USERNAME and SLUMBER_PASSWORD in order for everything to work properly.
RUN . /var/readthedocs/bin/activate \
    && python -c "import os;import sys;os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'readthedocs.settings.dev');sys.path.append(os.getcwd());from django.contrib.auth.models import User;admin = User.objects.create_user('admin','','admin');admin.is_superuser=True;admin.is_staff=True;admin.save();test = User.objects.create_user('test','','test');test.is_staff=True;test.save();"

# Now let's properly generate the static assets:
RUN . /var/readthedocs/bin/activate \
    && python ./manage.py collectstatic --noinput

# Finally, you're ready to start the webserver: python manage.py runserver

EXPOSE 8000

CMD . /var/readthedocs/bin/activate \
    && python ./manage.py runserver 0.0.0.0:8000
