# A reusable filtering solution

- The basic gist is this: You can call `Grant.filter(params.slice(:funder_by_id))` or even `Grant.pg_search(params[:q]).filter(params.slice(:funder_by_id))` from within a controller, and it will filter by any URL params you want, in this case, I'm filtering by the URL param `funder_by_id`.

# How it works

### View

- I got started by reading this blogpost: http://www.justinweiss.com/articles/search-and-filter-rails-models-without-bloating-your-controller/

- And this is the basic gameplan I used, though I needed some customization along the way, which I'll try to document here.

- My goal was to have checkboxes on my view page which would allow a user to filter grants by 1 or more organizations.

- Let's look first at the `html` file, then we'll talk about what happens on the backend.

```
<%= form_tag(grants_path, method: 'get', enforce_utf8: false) do %>
  <%= hidden_field_tag :q , params[:q] %>
  <h5>Filter results</h5>
  <p>Organization</p>
  <% all_unique_funders(Grant.pg_search(params[:q])).each do |funder| %>
    <div class="row collection-row">
      
      <%= check_box_tag 'funder_by_id[]', "#{funder.id}", check_params_for_funder(params, funder), id: funder.id %>
      <%= label_tag funder.id, funder.name, for: funder.id %>

    </div>
  <% end %>
  
  <%= submit_tag 'Submit', class: 'waves-effect waves-light btn', :name => nil %>
<% end %>
```

- This is the filter form that's within `app/views/index.html.erb`.

- Some key things to note here:
  
- the `all_unique_funders` line is a little hacky and can use some refactoring. The basic idea is that `all_unique_funders` is a helper function in `app/helpers/grants_helper.rb`. It looks like this:

```
def all_unique_funders(grants)
  funders = grants.map { |grant| grant.funder }
  funders.uniq
end
```

- It returns all the unique funders for a given set of grants.

- The `check_box_tag` line uses some html trickery. The `'funder_by_id[]'` creates the name of the checkbox. Putting `[]` on the checkbox name allows `params` in rails to get an array of all the checkboxes that are checked. 

- The value for the checkbox is `"#{funder.id}"`, which is the id of the funder.

- `check_params_for_funder` is another helper function. It's in `app/helpers/application_helper.rb`. It looks like this:
```
def check_params_for_funder(params, funder)
  if params[:funder_by_id]
    params[:funder_by_id].include?(funder.id.to_s)
  else
    false
  end
end
```
- It returns true if the URL contains the `funder_by_id` param, and if the `funder`'s ID is in URL parameters for `funder_by_id`, and returns false in all other cases. 
- It allows me to pre-check the checkboxes if they're in the URL params, or leave them unchecked in the funder.id is not in the URL params.

### Controller

- Once the user check's off some boxes (or not) in the filter field, Rails routes the request to grants#index, which looks like this:
```
def index
  if params[:q].present?
    @grants = Grant.pg_search(params[:q]).filter(params.slice(:funder_by_id))
    render 'index-results'
  else
    @grants = Grant.all
    @funders = Funder.all
  end
end
```
- The key line here is `@grants = Grant.pg_search(params[:q]).filter(params.slice(:funder_by_id))`
- the `.pg_search(params[:q])` is using the `pg_search` gem which I won't go into here.
- The key part for this tutorial is the `.filter(params.slice(:funder_by_id))`. This calls `filter` on the `Grant` model.

### Model

- The `filter` method lives in `app/models/concerns/filterable.rb` ... It looks like this:
```
module Filterable
  extend ActiveSupport::Concern

  module ClassMethods
    def filter(filtering_params)
      results = self.where(nil)
      filtering_params.each do |key, value|
          results = results.public_send(key, value) if value.present?
      end
      results
    end

  end
end
```
- This is pretty much straight out of the tutorial I linked to above. When this runs in my example, the `filtering_params` object would look like this if two checkboxes where checked:
```
{"funder_by_id"=>["2", "3"]}
```
- `public_send` will call the `funder_by_id` method on the Grant with the parameter of `["2", "3"]`. So it's like calling `Grant.funder_by_id(["1", "2"])`

- **BUT** it's super reusable and can be called with any model and any URL params!!!

- The `funder_by_id` method is a scope on the Grant model. It looks like this:

```
scope :funder_by_id, lambda { |funder_id| where('funder_id' => ApplicationController.helpers.handle_funder_id_or_ids(funder_id)) }
```

- The basic idea of the `ApplicationController.helpers.handle_funder_id_or_ids(funder_id)` part is based on this SO post: http://stackoverflow.com/a/8155276

- It's essentially equivalent to calling either `Grant.where(:funder_id => 1)` or `Grant.where(:funder_id => [1, 2])`. If you call the later, Rails will do an `OR` query and look for grants where the `funder_id` is either `1` or `2`. 

- The reason I have the ApplicationController.helpers.handle_funder_id_or_ids() method in here is that my value for `funder_id` at this point is either an str like `"1"` or an array where each element is a str, like `["1", "2"]`.  `ApplicationController.helpers.handle_funder_id_or_ids()` takes care of converting either all the str's to int's, which is what Postgres need to execute the query.

- ` ApplicationController.helpers.handle_funder_id_or_ids()` looks like this:

```
def handle_funder_id_or_ids(id_or_ids)
  """
  takes 
  either an str which is a number, but as a str
  or an array of these things
  returns 
  either the number as an int
  or an array where each element is an int
  """
  if id_or_ids.class == Array
    id_or_ids.map{ |str| str.to_i }
  else
    id_or_ids.to_i
  end
end
```

- It's (hopefully?) pretty self-explanatory.

### The SQL query

- At this point, the controller code `Grant.filter(params.slice(:funder_by_id))` will execute the following query...

```
SELECT "grants_grant".* FROM "grants_grant" WHERE "grants_grant"."funder_id" IN (2, 3)
```
