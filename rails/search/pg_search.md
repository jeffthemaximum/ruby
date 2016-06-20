# Setting up multisearch

### Rebuilding the search documents for a given class

- THIS IS SUPER IMPORTANT!!!

- Anytime you change the `:against` option on a given model class, the pg_search_documents table can become out of sync.

- You update it as a rake task by doing...

```
rake pg_search:multisearch:rebuild[Grant]
```

- And you can do it from within Ruby codez by doing...

```
PgSearch::Multisearch.rebuild(Grant)
```


### install

- In Gemfile

```
gem 'pg_search'
```

### Getting started

- in `app/models/grant.rb`

```
class Grant < ActiveRecord::Base
    include PgSearch
    self.table_name = "grants_grant"
end
```

- Before using multi-search, you must generate and run a migration to create the pg_search_documents database table.

```
$ rails g pg_search:migration:multisearch
$ rake db:migrate
```

### Setting fields to search

- A basic example looks like this:

```
class Flower < ActiveRecord::Base
  include PgSearch
  multisearchable :against => :color
end
```

- I used it in `app/models/grants.rb` like this:

```
class Grant < ActiveRecord::Base
    include PgSearch
    self.table_name = "grants_grant"
    multisearchable :against => [:search_description, :search_link]

    def search_description
      data['description']
    end

    def search_link
      data['link']
    end
end
```

# Using pg_search_scope

- Official documentation is here: https://github.com/jmnsf/pg_search#pg_search_scope

- Basic example:

- Just pass an Array if you'd like to search more than one column.

```
class Person < ActiveRecord::Base
  include PgSearch
  pg_search_scope :search_by_full_name, :against => [:first_name, :last_name]
end
```

- Now our search query can match either or both of the columns.

```
person_1 = Person.create!(:first_name => "Grant", :last_name => "Hill")
person_2 = Person.create!(:first_name => "Hugh", :last_name => "Grant")

Person.search_by_full_name("Grant") # => [person_1, person_2]
Person.search_by_full_name("Grant Hill") # => [person_1]
```

- YOU CAN DO THIS WITH JSONB! I'VE DONE IT!!!!

- First, you need to get the newest pg_search gem, and as of this writing, the only version that supports this is `pg_search 1.0.5`

- Add this to your Gemfile

```
gem 'pg_search', :git => 'https://github.com/jmnsf/pg_search.git'
```

- Then, in `app/models/grants.rb`

```
class Grant < ActiveRecord::Base
    include PgSearch
    self.table_name = "grants_grant"
    multisearchable :against => [:search_description, :search_link]

    pg_search_scope :pg_search_description, :against => PgSearch::Configuration::JsonbColumn.new(:data, 'description')

    def search_description
      data['description']
    end

    def search_link
      data['link']
    end
end
```

- A few things to notice here. First, the multisearchable works with methods, so you don't need any fanciness to get the json fields.
- With `pg_search_scope`, the `:against` option doesn't work with methods. 
- Instead, we add `PgSearch::Configuration::JsonbColumn.new(:data, 'description')`
- This searches the `data` column of the `Grant` objects for the `description` key.

# Querying PgSearch

- To get started

```
foo = PgSearch.multisearch("Delegated Director")
```

- this searches all the PgSearch:Document entries for all of the records that match the given query.

- To get back the grant record...

```
grant = foo.searchable
```