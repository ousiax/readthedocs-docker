FROM debian:jessie-slim
MAINTAINER qqbuby <qqbuby@gmail.com>

ENV RTD_REPO_DIR=/var/readthedocs \
    RTD_COMMIT=ec23bc9c9d0eef0821a165d11a3ce75f1f39d59c

# ADD ./sources.list /etc/apt/sources.list

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git \
        libxml2-dev \
        libxslt1-dev \
        libz-dev \
        python-dev \
        python-pip \
        python-setuptools \
        texlive-latex-recommended \
        texlive-fonts-recommended \
        texlive-formats-extra \
    && rm -rf /var/lib/apt/lists/*
    
RUN curl -ksSL https://github.com/rtfd/readthedocs.org/archive/$RTD_COMMIT.tar.gz | tar xz -C /tmp/ \
    && mkdir -p ${RTD_REPO_DIR} \
    && mv /tmp/readthedocs.org-${RTD_COMMIT}*/* /tmp/readthedocs.org-${RTD_COMMIT}*/.??* ${RTD_REPO_DIR} \
    && rm -rf /tmp/readthedocs.org-${RTD_COMMIT}*

WORKDIR ${RTD_REPO_DIR}

RUN pip install -r requirements.txt \
    && rm -rf ~/.cache /tmp/pip_build_root

RUN python ./manage.py migrate \
    && python -c "import os;import sys;os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'readthedocs.settings.dev');sys.path.append(os.getcwd());from django.contrib.auth.models import User;admin = User.objects.create_user('admin','','admin');admin.is_superuser=True;admin.is_staff=True;admin.save();test = User.objects.create_user('test','','test');test.is_staff=True;test.save();" \
    && python ./manage.py collectstatic --noinput

EXPOSE 8000

CMD ["python", "./manage.py", "runserver", "0.0.0.0:8000"]
