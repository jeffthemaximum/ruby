# Counter Cache

### The problem

- In McScrapeface, I was trying to order Funders by the count of the number of grants that each funder has. 
- Funders have many grants, grants belong to funders.
- I couldn't get this query down.

### The solution

- My basic solution was to follow this SO post: http://stackoverflow.com/a/16996960

- First, I added the following to `app/models/grant.rb`

```
class Grant < ActiveRecord::Base

  belongs_to :funder, counter_cache: true

end
```

- Where the `counter_cache: true` part is what I added.
- A counter cache: Used to cache the number of belonging objects on associations. For example, a comments_count column in a Post class that has many instances of Comment will cache the number of existent comments for each post.

- Next, you need to generate a migration to add a column to funders to keep track of the grant_count:

```
rails g migration AddJobsCountColumnToFunders
```

- This creates a migration file. I edit it to look like this:

```
class AddJobsCountColumnToFunders < ActiveRecord::Migration
  def change
    add_column :grants_funder, :grants_count, :integer, default: 0
  end
end

```

- notiice the table name is `grants_funder` ... this is because this table is created and named by Django, and this is the name Django gives it.

- Now, I ran

```
rake db:migrate
```

- Which creates the column on the `grants_funder` table for `grants_count`

- **Important** This step does not automagically update the value in the `grants_count` table.

- To do that, I made a custom rake task, which you can read about here: 