# Server config for Scrapie McScrapeface

- Setup a new DO droplet with Ubuntu 14.04
- Follow this tutorial for **Initial Server Setup with Ubuntu 14.04** https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-14-04#tutorial_series_32
- Follow this tutorial for **How To Set Up Django with Postgres, Nginx, and Gunicorn on Ubuntu 14.04** https://www.digitalocean.com/community/tutorials/how-to-set-up-django-with-postgres-nginx-and-gunicorn-on-ubuntu-14-04 ... but with these customizations...
    - `myproject` == `grants`
    - `myprojectuser` == `jeff`
    - `password` == `airjeff`
    - On the `Create and Configure a New Django Project` step... **don't** create a new project.
    - Instead, `git clone` experiment-grant-scapie-mcscrapeface which is currently hosted here: https://github.com/jeffthemaximum/experiment-grant-scapie-mcscrapeface
    - Pickup at `Complete Initial Project Setup`