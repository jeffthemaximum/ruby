# Forms with Models
- TODO
- See: part 5.2 here: http://guides.rubyonrails.org/getting_started.html

# Form objects

- Work for breaking up bloated models
    - See: http://railscasts.com/episodes/416-form-objects?view=asciicast
- Can also work for forms that aren't related to Models. Like form.Form in Django


# form objects with Models
- TODO
- See: http://railscasts.com/episodes/416-form-objects?view=asciicast

# form objects without Models
- You can make your own form class and use it as if it's a model, you just don't save it to the DB.
- First, make a folder in `app/forms`, or really, where ever you want.
- You don't have to tell Rails about any folders that you make in the `app` directory, it should load them automatically.
- Example with JeffReads:

----------

 1. Make `app/forms/github_user.rb`
```
class SearchForm
    include ActiveModel::Model

    attr_accessor :username

    validates :username, presence: true
end
```
 2. In `app/controller/search_controller.rb`, add `require 'github_user.rb'` to the top. THIS MAY NOT BE NECESSARY BUT COULDN'T GET IT TO WORK WITHOUT THIS. Then, use the `SearchForm` class as if it's a model. See below:
```
require 'github_user.rb'

class SearchController < ApplicationController

    def index
        @github_user_form = SearchForm.new
    end

    def create
        username = SearchForm.new(search_params)
    end

    private
        def search_params
            params.require(:search_form).permit(:username)
        end
end
```
3. Make this in your `html.erb` file. Notice the `url` here. It's from `rake routes`, where the route's `prefix` is `search_create` and the `verb` it accepts is `POST`. 
```
<%= form_for @github_user_form, url: search_create_path do |f| %>
       
    <%= f.text_field :username%>
    <%= f.label :username %>
    <%= f.submit 'Submit', class: 'waves-effect waves-light btn' %>

<% end %>
```