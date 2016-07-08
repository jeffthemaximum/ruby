# Deploying scrapie on Heroku

- This tutorial will document my process of deploying Scrapie on Heroku.
- This is a somewhat complex Heroku deploy, since scrapie involves two applications: the python scraper application and the Rails user-facing application.
- The python scraper is a little complicated because there is a worker (Celery background task) that is runs asyncronously.
- The rails user facing application is a little complicated because it connects to the same Postgres database as the scraper.

# Deploying the python scraper

- It's important that this happens first, because the python scraper is what actually creates the Postgres database. It has the `createdb` code.
- Later, the Rails app will connect to the existing Postgres DB that this python application creates.

### Guide tutorial
- I mostly followed this tutorial here, but I had to make a few tweaks: https://devcenter.heroku.com/articles/deploying-python
- And I also had to follow this tutorial, and I also made a few tweaks: https://devcenter.heroku.com/articles/celery-heroku
- Most of the tweaks are already incorporated into the code for the application that's hosted on Github here: https://github.com/jeffthemaximum/scraper-django-heroku

### What I did for the python app
- I had already created the virtual environment and app dependencies file (`requirements.txt`) before getting started, so I skipped those sections of the tutorial.
- My `procfile` initially looks like this:
```
web: gunicorn project.wsgi --log-file -
```
- **Important** this is not the final version of the `Procile`. I'll change it later in the tutorial to include the `Celery` worker.
- At this point, I could push to heroku. I pushed it to an app here: https://scrapie.herokuapp.com/
- There's not much to see there. It's mainly just using Django as a long running application at this point which can run the various scrapers. Later, I hope to setup some API endpoints there to return the grant data.
- Next, I had to setup my postgres database. Following the tutorial, I did:
```
heroku addons:create heroku-postgresql:hobby-dev
```
- And then, to create my database and run my Django migrations, I did
```
heroku run python manage.py migrate
```
- Next, I had to get my celery background tasks running. These are the grants scrapers which I run as cron jobs to scrape the various grants websites.
- In my project, they live here: https://github.com/jeffthemaximum/scraper-django-heroku/blob/master/grants/tasks.py
- I had to make sure both `Celery` was installed and `Redis` was installed on the Heroku dyno.
- To install `Celery`, I made sure I included this line in `requirements.txt`:
```
celery==3.1.18
```
- To install celery, I ran this command from the terminal:
```
heroku addons:create heroku-redis
```
- Within my python application, I had already created a celery app, so I could skip this part of the Heroku celery tutorial. 
- But, I had to configure my celery app to use the redis server that exists on the Heroku dyno. To do that, I added these lines to `project/settings.py`:
```
BROKER_URL = os.environ['REDIS_URL']
CELERY_RESULT_BACKEND = os.environ['REDIS_URL']
```
- Since Heroku creates an enviroment variable named `REDIS_URL`, these lines are enough to connect the Celery app on Heroku to the redis server on my Heroku dyno.
- Then, I added the following lines to my `Procfile`, so that the final `Procfile` looks like this:
```
web: gunicorn project.wsgi --log-file -
worker: celery -A project worker -B -l info
```
- The second line is what runs the Celery background tasks.
- After pushing these changes to Heroku, you need to run these lines from the terminal to finish the setup and start the worker:
```
heroku ps:scale worker=1
```
- That's a onetime thing though, and in the future, the `Procfile` will be enough to restart the worker and incorporate any changes.

### What I did for the Rails application
- For this one, I could pretty much exactly follow the tutorial: https://devcenter.heroku.com/articles/getting-started-with-rails4
- I had already started my app, so I could skip many of the first steps in the tutorial.
- I had to move this line in the `Gemfile` into the `group :development, :test` section, because Heroku gets mad if you even try to install Sqlite3:
```
gem 'sqlite3'
```
- To connect the Rails application to the Postgres database that I created earlier in the tutorial...
- http://stackoverflow.com/a/5981700 This stackoverflow post is wrong. This does not work!
- Heroku doesn't let you do that anymore.
- Instead, to customize the `DATABASE_URL` on the Heroku app, you need to do this: http://stackoverflow.com/a/35064286
- I had to include the `DATABASE_URL` in my `database.yml` file, which you can see here: https://github.com/jeffthemaximum/scraper-rails-heroku/blob/master/config/database.yml
- You can see that the basic strategy is the inlude a URL for the production database:
```
production:
  adapter: postgresql
  encoding: unicode
  database: grants
  url: *hidden*
```
- I hid the url here so noone on the internets could potentially steal it. This is also why I made my github repo private.
- The database URL that my Rails app is using has to be the same as the Database url that my Django app is using on Heroku. Since my Django app already setup that database, I could run this command from the terminal while within my Django application to find out what that URL is:
```
heroku config | grep DATABASE_URL
```
- After setting that url in my `database.yml` file, I was good to go.
- Following the tutorial, I could then do
```
heroku run rake db:migrate
```

**Update 7/8/2016**

- There's now some custom rake tasks to run, too. You should also run

```
heroku run rake admin:update_grant_count
```

- This makes sure the `grant_count` column on the `Funder` model is updated with the count of grants that each funder has.

- Following the tutorials and these tweaks, everything should be up and running!