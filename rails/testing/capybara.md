# Capybara

- Silly name for a gem, imo

- I first started using this to test the User signup page on Scrapie.

# Getting started

- Add `gem 'capybara` to `group :development, :test do` section of the Gemfile.

- bundle install

- In your project, you also need Rspec as a gem.

- At that point, do `rails generate integration_test user_pages`

- This makes a `spec/requests/` directory if it doesn't yet exist, and makes the file, `spec/requests/user_pages_spec.rb`

# Running the tests

- If you just want to run `spec/requests/user_pages_spec.rb`, do:

```
bundle exec rspec spec/requests/user_pages_spec.rb
```

- If you want to run all the tests in `spec/requests/`, do:

```
bundle exec rspec spec/requests/
```

- If you want to run ALL THE TESTS

```
bundle exec rspec spec/
```

# What's user-signup capybara look like?

- Here's my finished codes:

```
require 'rails_helper'
require 'spec_helper'

RSpec.configure do |config|
  config.include Capybara::DSL
end

RSpec.describe "UserPages", type: :request do

  subject { page }

  # describe "signup page" do

  #   it 'basic selector check' do 
  #     get signup_path

  #     { should have_selector('h1',    text: 'Signup!') }
  # end
  describe "signup" do

    # let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should create a user" do
        visit '/signup'
        fill_in "user[email]",                 :with => ""
        fill_in "Name",                  :with => "jeff"
        fill_in "Password",              :with => "ilovegrapes"
        fill_in "user[password_confirmation]", :with => "ilovegrapes"

        # post users_path, name: "Example User", email: "user@example.com", password: 'foobar', password_confirmation: 'foobar'
        expect { click_button "Create my account" }.not_to change(User, :count)
      end
    end

    describe "with valid information" do
      it "should create a user" do
        visit '/signup'
        fill_in "user[email]",                 :with => "alindeman@example.com"
        fill_in "Name",                  :with => "jeff"
        fill_in "Password",              :with => "ilovegrapes"
        fill_in "user[password_confirmation]", :with => "ilovegrapes"

        # post users_path, name: "Example User", email: "user@example.com", password: 'foobar', password_confirmation: 'foobar'
        expect { click_button "Create my account" }.to change(User, :count).by(1)
      end
    end
  end
end
```