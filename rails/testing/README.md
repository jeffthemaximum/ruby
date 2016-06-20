# Rspec
- RSpec is a Domain-Specific Language (DSL) for describing the behavior a developer expects to see under given circumstances, and each test sets up the circumstances and declares the expected outcome. If the outcome is different from the expectation, the developer sees an error, signaling them that they need to refactor their code.

# Getting started
- Follow this tutorial:
- https://www.launchacademy.com/codecabulary/learn-test-driven-development/rspec/setting-up-rpec
- Make the following change:
- the default test database in `database.yml` is:
```
test:
<<: *default
database: db/test.sqlite3
```
- This causes a problem because I'm using `jsonb` field, and only postgres supports jsonb.
- To change this, change the `database.yml` test database to:
```
test:
  adapter: postgresql
  encoding: unicode
  database: grantstest
  pool: 5
  username: jeff
  password: airjeff
```
- And then, you have to create the DB from the terminal, I think:
```
psql
CREATE DATABASE grantstest;
GRANT ALL PRIVILEGES ON DATABASE grantstest TO jeff;
```

- If you've made any changes to your DB, you normally just
```
rake db:migrate
```
- But this doesn't change the test DB. 
- After each DB change, you also need to do this:
```
bundle exec rake db:test:prepare
```

# Testing Users
- First test in `spec/models/user_spec.rb`
```
require 'spec_helper'

describe User do

  before { @user = User.new(name: "Example User", email: "user@example.com") }

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
end
```
- The `before` block runs before anything else. It creates a new user with name and email.
- `subject { @user }` makes `@user` the subject of the test.
- The `respond_to` blocks use the Ruby method `respond_to?` which accepts a symbol and returns true or false if the object responds to a method or attribute.
- The tests themselves rely on the boolean convention used by RSpec: the code:
```
@user.respond_to?(:name)
```
- can be tested using the RSpec code:
```
@user.should respond_to(:name)
```
- Because of subject `{ @user }`, we can leave off `@user` in the test, yielding:
```
it { should respond_to(:name) }
```

# Testing `validates` fields
- We can setup a test to look like this:
```
require 'spec_helper'

describe User do

  before do
    @user = User.new(name: "Example User", email: "user@example.com")
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }

  it { should be_valid }

  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid }
  end
end
```
- Here, the line `it { should be_valid }`...
- whenever an object responds to a boolean method foo?, there is a corresponding test method called be_foo.
- So for us
```
@user.valid?
```
- Is the same as
```
@user.should be_valid
```
- And since we've setup `subject { @user }`, we can do `it { should be_valid }`

# Helpful hints

- Use `.dup` to quickly create a duplicate object and test uniqueness
- Example:
```
describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.save
    end

    it { should_not be_valid }
end
```

# Running tests
- Run just one test
```
bundle exec rspec spec/models/user_spec.rb
```

- Run ALL THE TESTS!
```
bundle exec rspec spec/
```
