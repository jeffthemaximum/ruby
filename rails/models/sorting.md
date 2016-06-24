# Sorting with Scrapie

- This is a reusable sorting solution that would be applicable to Experiment
- Basic gameplan was to follow this tutorial, with a few key tweaks --> http://railscasts.com/episodes/228-sortable-table-columns?view=asciicast

### View

- The HTML to get this to work looks like this.
- I added these lines

```
<!-- in app/views/index-results.html.erb -->
<li class="collection-header">
  <p>
    Sort by: <span>
      <%= sortable_grants(column="data->'name'", title="Grant Name", other_params(params)) %>
    </span>
    <span>
      | <%= sortable_grants(column="data->'deadline'", title="Deadline", other_params(params)) %>
    </span>
  </p>
</li>
```

- To this file

```
<!-- in app/views/index-results.html.erb -->
<!-- results div -->
<div class="col s12 l9">
  <ul class="collection with-header">
    <li class="collection-header">
      <p>
        Sort by: <span>
          <%= sortable_grants(column="data->'name'", title="Grant Name", other_params(params)) %>
        </span>
        <span>
          | <%= sortable_grants(column="data->'deadline'", title="Deadline", other_params(params)) %>
        </span>
      </p>
    </li>

    <% @grants.each do |grant| %>
      <li class="collection-item avatar">
        <img class="circle" src="<%= image_src(grant) %>">
        <div class="row collection-row">
          <div class="col s9">
            <span class="title truncate"><%= grant.data['name'] %></span>
          </div>
        </div>
        <p><%= grant.funder.name %> <br>
          <%= grant.deadline_pretty_print %>
        </p>
        <%= link_to "Details", grant_path(grant), class: "secondary-content" %>
      </li>
    <% end %>

  </ul>
</div>
<!-- end filter -->
```

- The key things to note here...
- The `<li class="collection-header">` comes from materialize css and is basically the same as a `th` in a table.
- `<%= sortable_grants(column="data->'name'", title="Grant Name", other_params(params)) %>` is what gets the whole thing to work. It creates a link, and is a helper method. At the end, it will render out something like this:

```
<a href="/grants?direction=asc&amp;q=grant&amp;sort=data-%3E%27name%27">Grant Name</a>
```

- There's two helper methods here that we need to look at: `sortable_grants()` and `other_params`.

### Helpers

- In `app/helpers/application_helpers.rb`, we create the `sortable_grants()` method. It looks like this:

```
def sortable_grants(column, title=nil, **kwargs)
  title ||= column.titleize
  direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
  icon = sort_icon(column)
  link_to(title, :sort => column, :direction => direction, **kwargs) + icon.html_safe

end
```

- It also depends on two private methods from `app/controllers/grants.rb` : `sort_column()` and `sort_direction`. They look like this:

```
private
  def sort_column
    %w[data->'name' data->'deadline'].include?(params[:sort]) ? params[:sort] : "data->'name'"
    # params[:sort] || "data->'name'"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
  end
```

- The basic idea of `sortable_grants()` method... It takes a `column` parameter, which is used for a couple things. It's used mainly for including in the link tag that gets rendered out. The `link_to` builds a bunch of params on the URL. The `sort` param on the URL comes from the column. In my case, column will be something like `"data->'deadline'"`, since I'm trying to sort by the `deadline` value of the `data` jsonb object that's in the `grants` database in the `data` column. 
- Direction is set to either `asc` or `desc`, and the tutorial does a good job of explaining how this happens. If the column we’re generating the link for is the current sort column and the current direction is ascending then we’ll set the direction to desc so that the next time that field is clicked the column is sorted the other way. In all other cases we want the sort direction to be ascending.
- The `icon` is set by the `sort_icon` method, but I'm not includign anything about that here...
- `sort_column` and `sort_direction` are used to sanitizing the URL parameters.

- I'm pretty proud of the `**kwargs` part here. It allows us to keep track of all the URL parameters that are already being included. 
- I pass along the `params` to an `other_params()` method. It looks like this:

```
def other_params(params)
  params_to_hash(params.slice(:q, :funder_by_id))
end
```

- It passes along the `q` and `funder_by_id` parameters as `kwargs` to the `sortable_grants` method as a hash. You can see the whole method here --> https://github.com/jeffthemaximum/experiment-grant-scapie-mcscrapeface/blob/master/rails_frontend/app/helpers/application_helper.rb

### Controller

- The `index` method in the `grants_controller` ends up looking like this:

```
def index
  if params[:q].present?
    @grants = Grant.order(sort_column + ' ' + sort_direction).pg_search(params[:q]).filter(params.slice(:funder_by_id))
    render 'index-results'
  else
    @grants = Grant.all
    @funders = Funder.all
  end
end
```

- The only part needed for the sorting is this line: `@grants = Grant.order(sort_column + ' ' + sort_direction).pg_search(params[:q]).filter(params.slice(:funder_by_id))`. And specifically, this part `.order(sort_column + ' ' + sort_direction)`.
- The URL that comes into `index` will look something like this: `http://localhost:3000/grants?direction=desc&q=grant&sort=data->deadline`
- The `.order` method is looking at two params from the url: `direction` and `sort`. In this case, `direction=desc` and `sort=data->deadline`.
- Again, we use the `sort_column` method. In the case of the sample URL above, `sort_column` would return `"data->'deadline'"`. 
- Using the `sort_direction` method would return `"desc"`
- So the end results is the `Grant.order(sort_column + ' ' + sort_direction)` will be `Grant.order("data->'deadline'" + ' ' + "desc")`
- This will order the grants by the `deadline` value in the `data` json object. And it will do it in a `desc` order.
