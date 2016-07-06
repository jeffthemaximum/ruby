# Impressions

- The basic plan was to follow this SO post: http://stackoverflow.com/questions/4815713/simple-hit-counter-for-page-views-in-rails

# What I did

### impressionable module

- I made a file `lib/impressionable.rb` that contained the following:

```
module Impressionable
  def is_impressionable
    has_many :impressions, :as=>:impressionable
    include InstanceMethods
  end
  module InstanceMethods
    def impression_count
      impressions.size
    end

    def unique_impression_count
      impressions.group(:ip_address).size
    end
  end
end

ActiveRecord::Base.extend Impressionable
```

- This creates reusable code, basically a class, which allows these methods to be used in several models. In my case, I'll be using it with `Grants` and `Founders`.

- I also had to tell rails to autoload the modules, which is accomplished by adding the following line to `config/application.rb` ...

```
config.autoload_paths += %W(#{config.root}/lib) 
```

### Create a model

- I created a file `app/models/impression.rb` by doing `rails generate model Impression` ... I made `app/models/impression.rb` looks like this:

```
class Impression < ActiveRecord::Base
  belongs_to :impressionable, :polymorphic=>true 
end
```

- the `:polymorphic=>true` is the equivalent of a `generic foreign key` in Django, and basically allows impressionable to belong to any model.

- Under the covers, it does this by creating two columns on the `impressions` table in the database, so the table looks like this:

```
create_table "impressions", force: :cascade do |t|
  t.string   "impressionable_type"
  t.integer  "impressionable_id"
  t.integer  "user_id"
  t.string   "ip_address"
  t.datetime "created_at"
  t.datetime "updated_at"
end
```

- And when you query for an impression, you get something back like this:

```
<Impression id: 1, impressionable_type: "Grant", impressionable_id: 1455, user_id: 2, ip_address: "::1", created_at: "2016-07-06 18:11:41", updated_at: "2016-07-06 18:11:41">
```

- And you can see that each impression has an `impressionable_id`, which in this case is the id of the grant to which the impression belongs.
- It also has a `impressionable_type`, which in this case is the model name of the model to which the impresison belongs.

- Finally, I had to create a migration file. I did...

```
rails generate migration CreateImpressions
```

- And then I edited that file to look like this:

```
class CreateImpressions < ActiveRecord::Migration
  def self.up
    create_table :impressions, :force => true do |t|
      t.string :impressionable_type
      t.integer :impressionable_id
      t.integer :user_id
      t.string :ip_address
      t.timestamps
    end
  end

  def self.down
    drop_table :impressions
  end
end
```

- Running `rake db:migrate` finished this step.

### Grants have many impressions

- To setup this relationship, I edited `app/models/grants.rb` with the following way:

```
class Grant < ActiveRecord::Base

    ...

    include Impressionable
    is_impressionable

    ...

```

- This is enough to include the logic that I created in the previous step, where we made the `Impressionable` module.

### Grants controller

- I had to put logic in my grant controller to create an impression each time a user views a grant. `app/controllers/grants_controller.rb` ended up looking like this:

```
class GrantsController < ApplicationController
  before_filter :log_impression, :only=> [:show]

  ...

  def show
    @grant = Grant.find(params[:id])
    @recent_grants = Grant.order(:created_at).limit(3)
    # render 'show2'
  end

  ...

    def log_impression
      @grant = Grant.find(params[:id])
      unless current_user
        @grant.impressions.create(ip_address: request.remote_ip,user_id:current_user.id)
        @grant.funder.impressions.create(ip_address: request.remote_ip,user_id:current_user.id)
      else
        @grant.impressions.create(ip_address: request.remote_ip)
        @grant.funder.impressions.create(ip_address: request.remote_ip)
      end
    end
end
```

- First, I created a before_filter which calls the `log_impression` method whenever the `show` method is executed.
- The `log_impression` method finds the grant my it's id
- `unless current_user` checks to see if the user is logged in.
- If she is, I save the `current_user.id` along with the impression. 
- If she isn't, this `user_id` column is left as `nil`.
- You can see in my example that I also save impressions for funders, but I'm not discussing that in this tutorial. It uses identical logic to get setup.

### Impressions controller

- This step is optional, but demonstrates some common queries that you might do on impressions. I'll just leave it here for now...

```
class ImpressionsController < ApplicationController
  def index
    @impressions = Impression.all
  end

  def grants
    @impressions = Impression.where(impressionable_type: "Grant")
  end

  def funders
    @impressions = Impression.where(impressionable_type: "Funder")
  end

  def highest_grants
    @impressions = Impression.where(impressionable_type: "Grant").group('impressionable_id').order('count_impressionable_id').count('impressionable_id')
  end

  def highest_funders
    @impressions = Impression.where(impressionable_type: "Funder").group('impressionable_id').order('count_impressionable_id').count('impressionable_id')
  end
end
```