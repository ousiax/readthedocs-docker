FROM debian:jessie
MAINTAINER qqbuby <qqbuby@gmail.com>

ENV PIP_TIMEOUT=60 \
#    PIP_INDEX_URL=https://pypi.douban.com/simple \
    RTD_BASE_DIR=/var \
    RTD_REPO_DIR=${RTD_BASE_DIR}/readthedocs \
    RTD_COMMIT=ed4f90e4
    
# RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak \
#    && echo 'deb http://mirrors.163.com/debian stable main contrib non-free' > /etc/apt/sources.list

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git \
        libxml2-dev \
        libxslt1-dev \
        python-dev \
        python-pip \
    && rm -rf /var/lib/apt/lists/*
    
# Read the docs
# Creat a folder here, and clone the repository
RUN mkdir -p ${RTD_BASE_DIR}
WORKDIR ${RTD_BASE_DIR}
RUN curl -ksSL https://github.com/rtfd/readthedocs.org/archive/$RTD_COMMIT.tar.gz | tar xz \
    && mv readthedocs.org-${RTD_COMMIT}* ${RTD_REPO_DIR}

# Install the depedencies using pip (included inside of virtualenv),
# then please create a super account for Django,
# and create an account for API use and set SLUMBER_USERNAME and SLUMBER_PASSWORD in order for everything to work properly,
# then let's properly generate the static assets.
WORKDIR ${RTD_REPO_DIR}
RUN pip install -r requirements.txt \
    && rm -rf ~/.cache \
    && python ./manage.py migrate \
    && python -c "import os;import sys;os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'readthedocs.settings.dev');sys.path.append(os.getcwd());from django.contrib.auth.models import User;admin = User.objects.create_user('admin','','admin');admin.is_superuser=True;admin.is_staff=True;admin.save();test = User.objects.create_user('test','','test');test.is_staff=True;test.save();" \
    && python ./manage.py collectstatic --noinput

# Finally, you're ready to start the webserver: python manage.py runserver
EXPOSE 8000

CMD ["python", "./manage.py", "runserver", "0.0.0.0:8000"]
