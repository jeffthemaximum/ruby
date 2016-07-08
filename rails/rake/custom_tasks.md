# Custom rake tasks

- I had to add a custom rake task to McScrapeface to update the `grants_count` column I created for `Funders`.
- You can read about how I created that column here: https://github.com/jeffthemaximum/ruby/blob/master/rails/models/counter_cache.md

- To create the custom task...

- First, I did in the terminal: 

```
rails generate task UpdateGrantCount
```

- Which created a file `lib/tasks/update_grant_count.rake`
- I edited that file to look like this:

```
namespace :admin do
  desc "updates grant_count column on funders with count of associated grants"
  task :update_grant_count => :environment do
    Funder.find_each { |funder| Funder.reset_counters(funder.id, :grants) }
  end
end
```

- `task :update_grant_count => :environment` does two things.
- First, it names the task as `update_grant_count`
- Second, it imports all environment (variable?) so that you have access to `Funder`

- Now, to run this thing, you do:

```
rake admin:update_grant_count
```

- `admin` comes from the namespace in the task file, and `update_grant_count` comes from the task.