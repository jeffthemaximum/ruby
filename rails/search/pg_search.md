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