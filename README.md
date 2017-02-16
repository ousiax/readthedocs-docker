# ReadTheDocs (RTD) Docker 

The *ReadTheDocs (RTD) Docker* includes three branch: *master*, *uwsgi*, *compose*.

### 1. ***master***

[![](https://images.microbadger.com/badges/image/qqbuby/readthedocs.svg)](https://microbadger.com/images/qqbuby/readthedocs "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/qqbuby/readthedocs.svg)](https://microbadger.com/images/qqbuby/readthedocs "Get your own version badge on microbadger.com")

The *master* branch is a basic docker image that responds to the `qqbuby/readthedocs:latest`.

- `EXPOSE 80`
  
- `CMD ["python", "./manage.py", "runserver", "0.0.0.0:8000"]`
  
- ENV:

    `RTD_REPO_DIR:/var/readthedocs`
    
    `RTD_COMMIT=2a54e3adf487412f58a0a4473c0a52250b15ff18`

### 2. ***uwsgi***

 [![](https://images.microbadger.com/badges/image/qqbuby/readthedocs:uwsgi.svg)](https://microbadger.com/images/qqbuby/readthedocs:uwsgi "Get your own image badge on microbadger.com")
 [![](https://images.microbadger.com/badges/version/qqbuby/readthedocs:uwsgi.svg)](https://microbadger.com/images/qqbuby/readthedocs:uwsgi "Get your own version badge on microbadger.com")
     
 The *uwsgi* branch is a docker image that uses to set up the RTD with uWSGI, and responds to the `qqbuby/readthedocs:uwsgi`.

 For more about ***uWSGI***, please refer to [The uWSGI project](https://uwsgi-docs.readthedocs.io/en/latest/).

 For more about how to set up Django so that it works nicely with uWSGI and nginx, pleae refer to [Setting up Django and your web server with uWSGI and nginx](http://uwsgi-docs.readthedocs.io/en/latest/tutorials/Django_and_nginx.html). 
 
 - `USER readthedocs`
 - `EXPOSE 8191 8192`
 - `CMD ["uwsgi", "--ini", "readthedocs.ini:dev"]`
 - *readthedocs.ini*
 
     ```uwsgi
     [uwsgi]
     ini = :dev
     
     [dev]
     env = DJANGO_SETTINGS_MODULE=readthedocs.settings.dev
     ini = :readthedocs
     
     [readthedocs]
     chdir = /var/readthedocs
     wsgi-file = readthedocs/wsgi.py
     # module = django.core.handlers.wsgi:WSGIHandler()
     # module = readthedocs.wsgi:applicaiton
     
     http = 0.0.0.0:8000
     socket = 0.0.0.0:8192
     # socket = /var/run/readthedocs/uwsgi.sock
     # chmod-socket = 0666
     
     uid = readthedocs
     gid = readthedocs
     
     stats = 0.0.0.0:8191
     pidfile = /var/run/readthedocs/uwsgi.pid
     logto = /var/log/readthedocs/uwsgi.log
     # daemonize = /var/log/readthedocs/%n.log
     
     master = true
     workers = 4
     enable-threads = true
     
     vaccum = true
     ```
     
### 3. ***compose***

The *compose* branch uses the ***Docker Compose*** to set up and run *uwsgi* and *nginx*.

For more information about *Docker compsoe*, please refer to [Overview of Docker Compose](https://docs.docker.com/compose/overview/).

*docker-compose.yml*

```yml
version: '3'
services:
    readthedocs:
        container_name: helpcenter-readthedocs
        build: ./readthedocs
        command: /usr/local/bin/uwsgi /var/readthedocs/readthedocs.ini
        volumes:
            - readthedocs:/var/readthedocs
        environment:
            DEBUG: 'True'
            EMAIL_HOST: 'docs.example.com'
            EMAIL_PORT: 25
            EMAIL_HOST_USER: 'no-reply@example.com'
            EMAIL_HOST_PASSWORD: '123456'
            DEFAULT_FROM_EMAIL: 'no-reply@example.com'

    nginx:
        image: nginx
        container_name: helpcenter-nginx
        links:
            - readthedocs:readthedocs
        ports:
            - 80:80
        volumes:
            - readthedocs:/var/readthedocs:ro
            - ./nginx/readthedocs.conf:/etc/nginx/conf.d/default.conf
volumes:
    readthedocs:
```

*Avaliable environment variables in the image of `readthedocs` that use to custom Django's settings.*

```python
PRODUCTION_DOMAIN = 'docs.example.com'
PRODUCTION_DOMAIN = os.environ.get('PRODUCTION_DOMAIN', PRODUCTION_DOMAIN)

SLUMBER_API_HOST = 'http://{0}'.format(PRODUCTION_DOMAIN)
SLUMBER_API_HOST = os.environ.get('SLUMBER_API_HOST', SLUMBER_API_HOST)

PUBLIC_API_URL = 'http://{0}'.format(PRODUCTION_DOMAIN)
PUBLIC_API_URL = os.environ.get('PUBLIC_API_URL', PUBLIC_API_URL)

TIME_ZONE = os.environ.get('TIME_ZONE', 'Asia/Chongqing')
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_BACKEND = os.environ.get('EMAIL_BACKEND', EMAIL_BACKEND)
EMAIL_HOST = os.environ.get('EMAIL_HOST', 'localhost')
EMAIL_PORT = os.environ.get('EMAIL_PORT', 25)
EMAIL_HOST_USER = os.environ.get('EMAIL_HOST_USER', None)
EMAIL_HOST_PASSWORD = os.environ.get('EMAIL_HOST_PASSWORD', None)
DEFAULT_FROM_EMAIL = os.environ.get('DEFAULT_FROM_EMAIL', EMAIL_HOST_USER)
EMAIL_USE_TLS = os.environ.get('EMAIL_USE_TLS', None)
EMAIL_USE_SSL = os.environ.get('EMAIL_USE_SSL', None)

DEBUG = bool(os.environ.get('DEBUG', False))
```

- - -

*Please send me your feedback*.
