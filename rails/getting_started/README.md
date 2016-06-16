# Getting Started

- This tutorial will document the steps I used to start the `rails_frontend` project that was part of my Experiment grants scraper.

### Start Project

- Navigate to a folder in which you want to start your project.
- Then in terminal
```
rails new rails_frontend
```

- You can then cd into `blog/` to see `app\`, `bin\`, `config\`, etc.


### Connect to existing DB from Django app

- First step is to find the DB name and table name in your existing Postgres DB that you want to connect to, see below...

- using `psql` from terminal, get table name of existing table in the existing Postgres db

- In terminal:
```
psql
\l    # lists out all db's. I found 'grants' db
\connect grants
\dt   # lists all tables in the 'grants' db. I found 'grants_grant'
```

- Second step is to take that DB name and table name info and put it in the `database.yml` file. See below...
```
# In 'config\database.yml'

development:
  adapter: postgresql
  encoding: unicode
  database: grants
  pool: 5
  username: jeff
  password: airjeff
```

### Create a model in Rails that connects to the grants_grant table

- First, make your model...
```
rails generate model Grant
```
- Second, change the table name of the model
```
# in 'app/models/grant.rb'

class Grant < ActiveRecord::Base
    self.table_name = "grants_grant"
end
```

- **Important to note here:** the "grants_grant" table name is the name of the table that already exists in the Postgres database. It's the tablename I found back in the `Connect to existing DB from Django app` section.

### Now that you've got ur model, try to add it to routes.rb

- 

### Start landing page

- `cd` into `rails_frontend`. 