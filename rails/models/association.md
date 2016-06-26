# Associations
### How to make a many-to-many?
#### has_and_belongs_to_many
- This is the bad way to do things. Makes it harder to create associations.
- Example:
```
# app/model/Bookmark.rb
class Bookmark < ActiveRecord::Base
  has_and_belongs_to_many :lists
end

# app/model/List.rb
class List < ActiveRecord::Base
  has_and_belongs_to_many :bookmarks
end
```
- create a new migration 
```
rails generate migration CreateJoinTableListBookmark List Bookmark
```
- Migrate
```
rake db:migrate
```

#### has_many through
- This is the better way to do things. It makes it easier to create and query relationships.
- Example, where we want a programmer to have many clients, and a client to have many programmers.
- First, create your three tables:
```
rails g model Programmer name:string
rails g model Client name:string
rails g model Project programmer:references client:references
rake db:migrate
```
- Next, setup your models.rb files
```
# app/model/programmer.rb
class Programmer < ActiveRecord::Base
  has_many :projects
  has_many :clients, through: :projects
end

# app/model/project.rb
class Projects < ActiveRecord::Base
  belongs_to :programmer
  belongs_to :client
end

# app/model/client.rb
class Client < ActiveRecord::Base
  has_many :projects
  has_many :programmers, through: :projects
end
```
- Then, to create associations:
```
programmer = Programmer.create(name: 'Josh Frankel')
client     = Client.create(name: 'Mr. Nic Cage')

programmer.projects.create(client: client)
```

- Finally, to query associations
```
programmer.clients
```

# On scrapie, I had to do this slightly different

### the problem

- Scrapie had some trouble with the above tutorial. This is because doing

```
rails g model GrantUserRelationship grant:references user:references
```

- Made a migration file that looked like this:

```
class CreateGrantUserRelationshis < ActiveRecord::Migration
  def change
    create_table :grant_user_relationshis do |t|
      t.references :grant, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
```

- And this line `t.references :grant, index: true, foreign_key: true` wouldn't work. Rails was looking for a model `Grant` and a table `grant` when it tried to run this migration. But, my table is called `grants_grant`. So the migration would fail to find the table `grant`, and would run. 

### the solution

- I followed the pattern in Michael Hartl's tutorial: https://www.railstutorial.org/book/following_users

- First, I created a migration like this:

```
rails g model GrantUserRelationship grant_id:integer user_id:integer
```

- Notice that I do `grant_id:integer` in this migration, insteal of `grant:references` like I did in the buggy migration.

- Then, I edited the migration file so that it looks like this:

```
class CreateGrantUserRelationships < ActiveRecord::Migration
  def change
    create_table :grant_user_relationships do |t|
      t.integer :grant_id
      t.integer :user_id

      t.timestamps null: false
    end
    add_index :grant_user_relationships, :grant_id
    add_index :grant_user_relationships, :user_id
    add_index :grant_user_relationships, [:grant_id, :user_id], unique: true
  end
end
```

- Then, within each model file, I set them up like this to get them to work...

```
# in app/models/grant.rb
class Grant < ActiveRecord::Base

...

    has_many :grant_user_relationships, foreign_key: :grant_id
    has_many :users, through: :grant_user_relationships

...
```

```
# in app/models/user.rb
class User < ActiveRecord::Base

...

  has_many :grant_user_relationships, foreign_key: :user_id
  has_many :grants, through: :grant_user_relationships, dependent: :destroy

...
```

```
# in app/models/grant_user_relationship.rb
class GrantUserRelationship < ActiveRecord::Base
  belongs_to :grant
  belongs_to :user
  validates :grant_id, presence: true
  validates :user_id, presence: true
end
```

- The key difference here is that I need the `foreign_key: :grant_id` in `app/models/grant.rb` and `foreign_key: :user_id` in `app/models/user.rb`. 

- This is because I didn't use the `references` command in my generate. I had to explicitly tell rails how to use the foreign keys.