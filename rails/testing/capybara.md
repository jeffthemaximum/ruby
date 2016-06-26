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