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

- You'll also have to add `gem 'pg'` inside `Gemfile` for this to work.

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

- **Another important note here:** when you run `rails generate model Grant`, Rails automagically creates a migration file. In my case, this file is `db/migrate/20160616161544_create_grants.rb`. If you run `rake db:migrate` at this point, you'll `create_table(:grants)`. In my case, this isn't a problem, because the table I'm connected to is called `grants_grant`. However, this could cause a conflict if you already had a table called `grants` in the db. I'm not sure what Rails would do in the case of this conflict. To avoid this situation, you could just get rid of that migration file, though this may not be Rails best practice. I imagine you could edit that migration file, too.

### Now that you've got ur model, try to add it to routes.rb

```
# within 'app/config/routes.rb add...

resources :grants
``` 

- now, if you `rake routes` from the terminal, you should see:
```
    Prefix Verb   URI Pattern                Controller#Action
    grants GET    /grants(.:format)          grants#index
           POST   /grants(.:format)          grants#create
 new_grant GET    /grants/new(.:format)      grants#new
edit_grant GET    /grants/:id/edit(.:format) grants#edit
     grant GET    /grants/:id(.:format)      grants#show
           PATCH  /grants/:id(.:format)      grants#update
           PUT    /grants/:id(.:format)      grants#update
           DELETE /grants/:id(.:format)      grants#destroy
```
- However, you won't yet be able to hit any of those routes, cuz you don't habve a controller yet...

### make a controller for grants

- From your terminal:
```
rails generate controller grants
```
- **Important to notice!!** when you `generate controller`, it's singular. When you `generate model` it's plural. **Question: ** Why?

- Now, if you go to `/grants`, you still won't be able to see a template. This is because you haven't put any logic in your `grants#index` controller, and you haven't made a template in `app/views/grants`

- We'll put in some **basic** controller logic, and then well make the template...

- Basic controller logic:
- In `app/controllers/grants.rb`...
- At first, if you haven't changed anything, it should look like this...
```
class GrantsController < ApplicationController
end
```

- And to add some logic for `index`, we change it to look like this:
```
class GrantsController < ApplicationController
    def index
        @grants = Grants.all
    end
end
```

- This should be enough to send all the grants over to the template.

### Make a template for the `grants#index` controller

- make `index.html.erb` inside `app/views/grants`.

```
# in app/views/grants/index.html.erb

<div class="container">
    <% @grants.each do |grant| %>
        <p>
            <%= grant.data %>
        </p>
    <% end %>    
</div>
```

- If you head to the browser now and go to `http://localhost:3000/grants`, you should see a big dump of data.

### converting `.html.erb` to `.slim`
- TODO
### Start landing page

- TODO