# FAQ's
####I already made a model, how do I add a column?
```
rails generate migration AddGoodIDToBook good_id:integer
rake db:migrate
```

# Generate
- makes a model and a migration file. 
- Need to do rake db:migrate afterwards
- Example:
    - `rails generate model Article title:string articles:text`
- Options for type of field:type ...
```
:primary_key, :string, :text, :integer, :float, :decimal, :datetime, :timestamp,
:time, :date, :binary, :boolean, :references
```
- See more here: http://stackoverflow.com/questions/4384284/rails-generates-model-fieldtype-what-are-the-options-for-fieldtype

- Generate makes a migration file. When you run that migration file with `rake db:migrate` you get a table in the db.
- You can see that table schema in `db/schema.db`

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

# Creating models

#### find_or_create_by and find_or_initialize_by
- Example:
- 


# Model validations
- Allow you to ensure that the data you're putting into the db is valid. For example, you can check a email address is valid.
- There are several ways to validate data before saving it to db. The main ones are:
    - Native db validations
    - client side validations
    - controller-level validations
    - model-level validations
- Model level are usually the most reliable choice, for various reasons, put all have their places.
#### Methods that trigger validation
- `new_record?` checks if a record is already in DB. Example:
```
>> p = Person.new(:name => "John Doe")
=> #<Person id: nil, name: "John Doe", created_at: nil, :updated_at: nil>
>> p.new_record?
=> true
>> p.save
=> true
>> p.new_record?
=> false
```
####  Methods that trigger validation
- The following methods trigger validations, and will save the object to the database only if the object is valid:
```
create
create!
save
save!
update
update_attributes
update_attributes!
```
- The bang versions raise an exception if record is invalid, the non-bang return `false`.
####  Methods that don't trigger validation
- The following methods save an object, but don't run validations (USE WITH CAUTION!):
```
decrement!
decrement_counter
increment!
increment_counter
toggle!
touch
update_all
update_attribute
update_column
update_counters
```

#### valid? and invalid?
- Trigger validations, but don't save
- Example:
```
class Person < ActiveRecord::Base
  validates :name, :presence => true
end
 
Person.create(:name => "John Doe").valid? # => true
Person.create(:name => nil).valid? # => false
```

#### errors
- Note that an object instantiated with new will not report errors even if it’s technically invalid, because validations are not run when using new.
- Example:
```
class Person < ActiveRecord::Base
  validates :name, :presence => true
end
 
>> p = Person.new
=> #<Person id: nil, name: nil>
>> p.errors
=> {}
 
>> p.valid?
=> false
>> p.errors
=> {:name=>["can't be blank"]}
 
>> p = Person.create
=> #<Person id: nil, name: nil>
>> p.errors
=> {:name=>["can't be blank"]}
 
>> p.save
=> false
 
>> p.save!
=> ActiveRecord::RecordInvalid: Validation failed: Name can't be blank
 
>> Person.create!
=> ActiveRecord::RecordInvalid: Validation failed: Name can't be blank
```
# record.errors[:base]
- Errors added to record.errors[:base] relate to the state of the record
as a whole, and not to a specific attribute.
- See `validates_with` in this tutorial for example

# validate
- used for custom validation methods
- calls a method when you try to validate the model
- Example (from my URL shortner)
```
class Url < ActiveRecord::Base
    validate :valid_url

    def valid_url
        url = URI.parse(self.url) rescue false
        if !url.kind_of?(URI::HTTP) && !url.kind_of?(URI::HTTPS)
            errors.add(:url, "invalid url")
        end
    end
```
# validates_with
- This helper passes the record to a separate class for validation.
- Example
```
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if record.first_name == "Evil"
      record.errors[:base] << "This person is evil"
    end
  end
end
 
class Person < ActiveRecord::Base
  validates_with GoodnessValidator
end
```

# before_create
- calls a method before saving a model to the db
- a "callback" function that executes when the model is saved (I THINK when it's saved for the first time, and not on updates)
- Example (from my URL shortner)
```
class Url < ActiveRecord::Base
    before_create :make_key
    validate :valid_url

    def valid_url
        ...
    end

    private
        def make_key
            self.key = random_str(6)
        end
        
        def random_str(length)
            ...
        end
```
# Validation helpers
#### acceptance
- used for checking if a user has checked a checkbox, like with TOS
- example:
```
class Person < ActiveRecord::Base
  validates :terms_of_service, :acceptance => true
end
```
#### validates_associated
- You should use this helper when your model has associations with other models and they also need to be validated. When you try to save your object, valid? will be called upon each one of the associated objects.
- example:
```
class Library < ActiveRecord::Base
  has_many :books
  validates_associated :books
end
```
- Don’t use validates_associated on both ends of your associations. They would call each other in an infinite loop.

#### confirmation
- Used when you have two text fields that should get exactly the same input. Useful for passwords when registering users. It creates  a `virtual attribute`, which is the field name with `_confirmation` appended.
- Example:
```
class Person < ActiveRecord::Base
  validates :email, :confirmation => true
  validates :email_confirmation, :presence => true
end

// and in an html.erb file
<%= text_field :person, :email %>
<%= text_field :person, :email_confirmation %>
```

#### exclusion
- This helper validates that the attributes’ values are not included in a given set. In fact, this set can be any enumerable object.
- Example: 
```
class Account < ActiveRecord::Base
  validates :subdomain, :exclusion => { :in => %w(www us ca jp),
    :message => "Subdomain %{value} is reserved." }
end
```

#### format
- This helper validates the attributes’ values by testing whether they match a given regular expression, which is specified using the :with option.
- Example
```
class Product < ActiveRecord::Base
  validates :legacy_code, :format => { :with => /\A[a-zA-Z]+\z/,
    :message => "Only letters allowed" }
end
```

#### inclusion
- This helper validates that the attributes’ values are included in a given set. In fact, this set can be any enumerable object.
- The inclusion helper has an option :in that receives the set of values that will be accepted. The :in option has an alias called :within that you can use for the same purpose, if you’d like to.
- Example
```
class Coffee < ActiveRecord::Base
  validates :size, :inclusion => { :in => %w(small medium large),
    :message => "%{value} is not a valid size" }
end
```

#### length
- This helper validates the length of the attributes’ values. It provides a variety of options, so you can specify length constraints in different ways:
- The possible length constraint options are:
```
:minimum – The attribute cannot have less than the specified length.
:maximum – The attribute cannot have more than the specified length.
:in (or :within) – The attribute length must be included in a given interval. The value for this option must be a range.
:is – The attribute length must be equal to the given value.
```
- Example:
```
class Person < ActiveRecord::Base
  validates :name, :length => { :minimum => 2 }
  validates :bio, :length => { :maximum => 500 }
  validates :password, :length => { :in => 6..20 }
  validates :registration_number, :length => { :is => 6 }
end
```

#### numericality
- This helper validates that your attributes have only numeric values. By default, it will match an optional sign followed by an integral or floating point number. To specify that only integral numbers are allowed set :only_integer to true.
- Example
```
class Player < ActiveRecord::Base
  validates :points, :numericality => true
  validates :games_played, :numericality => { :only_integer => true }
end
```
- Other optional constraints:
```
:greater_than – Specifies the value must be greater than the supplied value. The default error message for this option is “must be greater than %{count}”.

:greater_than_or_equal_to – Specifies the value must be greater than or equal to the supplied value. The default error message for this option is “must be greater than or equal to %{count}”.

:equal_to – Specifies the value must be equal to the supplied value. The default error message for this option is “must be equal to %{count}”.

:less_than – Specifies the value must be less than the supplied value. The default error message for this option is “must be less than %{count}”.

:less_than_or_equal_to – Specifies the value must be less than or equal the supplied value. The default error message for this option is “must be less than or equal to %{count}”.

:odd – Specifies the value must be an odd number if set to true. The default error message for this option is “must be odd”.

:even – Specifies the value must be an even number if set to true. The default error message for this option is “must be even”.
```
#### presence
- Checks that a value is not empty. Checks if it's `nil` or a blank string. A blankl string could be an empty string, or a string that contains only whitespace.
- Example:
```
class Person < ActiveRecord::Base
  validates :name, :login, :email, :presence => true
end
```
- Can also be used to test whether an association is present. To do this, you can check whether the foreign key used to map the association is present.
- Example:
```
class LineItem < ActiveRecord::Base
  belongs_to :order
  validates :order_id, :presence => true
end
```

#### uniqueness
- This helper validates that the attribute’s value is unique right before the object gets saved. 
- Example:
```
class Account < ActiveRecord::Base
  validates :email, uniqueness: true
end
```
----------

- IMPORTANT: It does not create a uniqueness constraint in the database, so it may happen that two different database connections create two records with the same value for a column that you intend to be unique. To avoid that, you must create a unique index in your database.
- To specify uniqueness on a database level, do
- `rails generate model user email:string:uniq` This will ensure the email is unique when it's saved to the db.
- If you want to add uniqueness later, do
- `rails g migration add_index_to_table_name column_name:uniq` ...or... `rails g migration add_index_to_table_name column_name:type:uniq`
- Example: `rails g migration add_index_to_customers customerID:integer:uniq`

----------

# Common validation options
- See part 3 here: http://guides.rubyonrails.org/active_record_validations.html#common-validation-options

# Conditional validations
- Example
```
class Order < ActiveRecord::Base
  validates :card_number, presence: true, if: :paid_with_card?
 
  def paid_with_card?
    payment_type == "card"
  end
end
```
- See more in part 5 here: http://guides.rubyonrails.org/active_record_validations.html#common-validation-options
