# Server config for Scrapie McScrapeface

## Getting django_backend running

- Setup a new DO droplet with Ubuntu 14.04
- Follow this tutorial for **Initial Server Setup with Ubuntu 14.04** https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-14-04#tutorial_series_32
- Follow this tutorial for **How To Set Up Django with Postgres, Nginx, and Gunicorn on Ubuntu 14.04** https://www.digitalocean.com/community/tutorials/how-to-set-up-django-with-postgres-nginx-and-gunicorn-on-ubuntu-14-04 ... but with these customizations...
    - `myproject` == `grants`
    - `myprojectuser` == `jeff`
    - `password` == `airjeff`
    - On the `Create and Configure a New Django Project` step... **don't** create a new project.
    - Instead, `git clone` experiment-grant-scapie-mcscrapeface which is currently hosted here: https://github.com/jeffthemaximum/experiment-grant-scapie-mcscrapeface
    - Then
    ```
    virtualenv env
    pip install -r requirements.txt
    source env/bin/activate
    ```
    - Pickup at `Complete Initial Project Setup`
    - When you try to `python manage.py migrate` you may get an error that says something similar to:

    ```
    django.db.utils.ProgrammingError: type "jsonb" does not exist
    ```

    - This happens if you're running any postgres less that 9.4
    - To upgrade to 9.4, follow this tutorial, which is AMAZING! https://medium.com/@tk512/upgrading-postgresql-from-9-3-to-9-4-on-ubuntu-14-04-lts-2b4ddcd26535#.smjuxnm8u
    - `gunicorn.conf` should look like:
    ```
    description "Gunicorn application server handling django_backend"
    
    start on runlevel [2345]
    stop on runlevel [!2345]
    
    respawn
    setuid jeff
    setgid www-data
    chdir /home/jeff/experiment-grant-scapie-mcscrapeface/django-backend
    
    exec ../env/bin/gunicorn --workers 3 --bind unix:/home/jeff/home/jeff/experiment-grant-scapie-mcscrapeface/django-backend/$
    ```
    - At this point Django app should be running on DO (tho I was a little drunk at this point, so I may be leaving out a few steps.)

## Getting Rails app running

- Follow this tutorial **How To Install Ruby on Rails with rbenv on Ubuntu 14.04** : https://www.digitalocean.com/community/tutorials/how-to-install-ruby-on-rails-with-rbenv-on-ubuntu-14-04
- Make the following changes
    - On the `rbenv install...` step, it failed for me. Instead, I had to do: `CONFIGURE_OPTS="--disable-install-doc" rbenv install 2.2.3`
- Follow this tutorial **How To Deploy a Rails App with Unicorn and Nginx on Ubuntu 14.04** https://www.digitalocean.com/community/tutorials/how-to-deploy-a-rails-app-with-unicorn-and-nginx-on-ubuntu-14-04

## Running django_backend and rails_frontend on the same DO droplet

- This is possible. I've done it! It's running here:
- django_backend: http://192.241.132.18:8000/
- rails_frontend: http://192.241.132.18/grants
- The key here is to have nginx setup as the reverse proxy to django_backend's gunicorn server and rails_frontend's unicorn server.
- They way I did this...
- First, for django_backend, I put a file made a nginx config file according to **How To Set Up Django with Postgres, Nginx, and Gunicorn on Ubuntu 14.04** https://www.digitalocean.com/community/tutorials/how-to-set-up-django-with-postgres-nginx-and-gunicorn-on-ubuntu-14-04
- That nginx file, for me, was /etc/nginx/sites-available/django_backend
- The contents of the file was:
```
server {
    listen 8000;
    server_name 192.241.132.18;

    location = /favicon.ico { access_log off; log_not_found off; }
    location /static/ {
        root /home/jeff/experiment-grant-scapie-mcscrapeface/django-backend;
    }

    location / {
        include proxy_params;
        proxy_pass http://unix:/home/jeff/experiment-grant-scapie-mcscrapeface/django-backend/django_backend.sock;
    }
}
```
- The only difference between this file and the nginx config file described in the tutorial that I've linked above is the `listen 8000;` line.
- Importantly, following the directions in the tutorial I linked above, you also need to like this django_backend nginx config file to the nginx sites-enabled with this line `sudo ln -s /etc/nginx/sites-available/myproject /etc/nginx/sites-enabled` ... where `myproject` is the path to django_backend
- For the rails_frontend, I setup a second nginx config file, and I followed the directions in **How To Deploy a Rails App with Unicorn and Nginx on Ubuntu 14.04** https://www.digitalocean.com/community/tutorials/how-to-deploy-a-rails-app-with-unicorn-and-nginx-on-ubuntu-14-04 
- My exact rails_frontend nginx config file was at `/etc/nginx/sites-available/default` and the contents of it where:
```
upstream app {
    # Path to Unicorn SOCK file, as defined previously
    server unix:/home/jeff/experiment-grant-scapie-mcscrapeface/rails_frontend/shared/sockets/unicorn.sock fail_timeout=0;
}

server {
    listen 80;
    server_name localhost;

    root /home/jeff/experiment-grant-scapie-mcscrapeface/rails_frontend/public;

    try_files $uri/index.html $uri @app;

    location @app {
        proxy_pass http://app;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;
    }

    error_page 500 502 503 504 /500.html;
    client_max_body_size 4G;
    keepalive_timeout 10;
}
```

## Celery/Redis config

- From a high-level, the gameplan to setup celery / redis as a task queue for the scraper comes from this tutorial: https://realpython.com/blog/python/asynchronous-tasks-with-django-and-celery/
- The basic idea is that the scraper exists within a Django app called django_backend
- Right now, the main feature of this app is to run the scraper every hour. Potentially, once I'm confident this hourly schedule is working, I'll cut it down to once every day. 
- The schedule for the scraping task exists within `django_backend/grants/tasks.py`
- On the Digitial Ocean droplet, to get it running, follow the plan outlined in the `Running Remotely` section of the tutorial that I linked to above.
- There's a `django_backend.conf` file that exists in the `/etc/supervisor/conf.d/` directory on the DO server. 
- It looks like this:
```
; the name of your supervisord program
[program:django_backend]

; Set full path to celery program if using virtualenv
command=/home/jeff/experiment-grant-scapie-mcscrapeface/django-backend/env/bin/celery worker -A project --loglevel=INFO

; The directory to your Django project
directory=/home/jeff/experiment-grant-scapie-mcscrapeface/django-backend

; If supervisord is run as the root user, switch users to this UNIX user account
; before doing any processing.
user=jeff

; Supervisor will start as many instances of this program as named by numprocs
numprocs=1

; Put process stdout output in this file
stdout_logfile=/var/log/celery/django_backend_worker.log

; Put process stderr output in this file
stderr_logfile=/var/log/celery/django_backend_worker.log

; If true, this program will start automatically when supervisord is started
autostart=true

; May be one of false, unexpected, or true. If false, the process will never
; be autorestarted. If unexpected, the process will be restart when the program
; exits with an exit code that is not one of the exit codes associated with this
; process’ configuration (see exitcodes). If true, the process will be
; unconditionally restarted when it exits, without regard to its exit code.
autorestart=true

; The total number of seconds which the program needs to stay running after
; a startup to consider the start successful.
startsecs=10

; Need to wait for currently executing tasks to finish at shutdown.
; Increase this if you have very long running tasks.
stopwaitsecs = 600

; When resorting to send SIGKILL to the program to terminate it
; send SIGKILL to its whole process group instead,
; taking care of its children as well.
killasgroup=true

; if your broker is supervised, set its priority higher
; so it starts first
priority=998
```

- and there's a `django_backend_beat.conf` file that exists in the `/etc/supervisor/conf.d/` directory on the DO server. 
- It looks like this:
```
; the name of your supervisord program
[program:django_backend_beat]

; Set full path to celery program if using virtualenv
command=/home/jeff/experiment-grant-scapie-mcscrapeface/django-backend/env/bin/celerybeat -A project --loglevel=INFO

; The directory to your Django project
directory=/home/jeff/experiment-grant-scapie-mcscrapeface/django-backend

; If supervisord is run as the root user, switch users to this UNIX user account
; before doing any processing.
user=jeff

; Supervisor will start as many instances of this program as named by numprocs
numprocs=1

; Put process stdout output in this file
stdout_logfile=/var/log/celery/django_backend_beat.log

; Put process stderr output in this file
stderr_logfile=/var/log/celery/django_backend_beat.log

; If true, this program will start automatically when supervisord is started
autostart=true

; May be one of false, unexpected, or true. If false, the process will never
; be autorestarted. If unexpected, the process will be restart when the program
; exits with an exit code that is not one of the exit codes associated with this
; process’ configuration (see exitcodes). If true, the process will be
; unconditionally restarted when it exits, without regard to its exit code.
autorestart=true

; The total number of seconds which the program needs to stay running after
; a startup to consider the start successful.
startsecs=10

; if your broker is supervised, set its priority higher
; so it starts first
priority=999
```

- To get these things running on DO, do from the terminal, after following the tutorial:
```
sudo supervisorctl start django_backend
sudo supervisorctl start django_backend_beat
```