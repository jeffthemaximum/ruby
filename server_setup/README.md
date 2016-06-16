# Server config for Scrapie McScrapeface

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
    - a