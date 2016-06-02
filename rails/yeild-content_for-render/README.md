# yield, content_for, render

 - use partials to make page rendering more dynamic

# render

 - from Rails
 - seems to be literally just a copy/paste
 - When you call render, it renders
 - example:
 ```
 <%= render 'layouts/navbar' %>
 ```
 - This will just find `views/layouts/_navbar.html.erb` and render it into the appropriate spot.

# yield and content_for

 - yield is from Ruby
 - it's used for dynamic data that changes depending on the page
 - Example with page titles....
```
// in index.html.erb
 
 <% content_for :title do %>
Home
<% end %>

<h1>Welcome!</h1>

// and in application.html.erb

<html>
<head>
  <title><%= yield :title %> | JeffReads</title>
</head>
...
```

 - First, put `content_for` in the lower page. `content_for` takes an argument, which is has to be the same argument that you pass to `yield` in the parent template. Then, put the `yield` function in the parent, and pass it the same argument name, in this case, `:title`.
 - You can also use `content_for?` within the parent.
 - Example with title:
```
 // in application.html.erb

<html>
<head>
  <title><%= content_for?(:title) ? yield(:title) : "Jeff" %> | JeffReads</title>
</head>
```

 - This will render the `:title` from `index.html.erb` if there's a title, otherwise will render `Jeff` as the page title.

# Using nested layouts

 - By default, Rails will look for `application.html.erb` as the base of a page. It will replace the unnamed `yield` block in `application.html.erb` with whatever is in your child page. 
 - For example
```
// application.html.erb

<!DOCTYPE html>
<html>
<head>
  <title><%= content_for?(:title) ? yield(:title) : "Jeff" %> | JeffReads</title>
  <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true %>
  <%= javascript_include_tag 'application', 'data-turbolinks-track' => true %>
  <%= csrf_meta_tags %>
</head>
<body>

    <%= yield :application_navbar %>

<%= yield %>

</body>
</html>


// and in search/index.html.erb

<h1>Welcome!</h1>
```
- When you render `search/index.html.erb`, Rails will put the `Welcome!` into the `yield` of `application.html.erb`
#### If you want a different base, other than `application.html.erb`...
- give it the name of the app. For example, if we have `search/index.html.erb`, we can make a file `layouts/search.html.erb`. This will make `search.html.erb` the new base for all templates in the search app.

- If you want the `search.html.erb` base to inherit from the `application.html.erb` base...
```
// in layouts/application.html.erb

<!DOCTYPE html>
<html>
<head>
  <title><%= content_for?(:title) ? yield(:title) : "Jeff" %> | JeffReads</title>
  <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true %>
  <%= javascript_include_tag 'application', 'data-turbolinks-track' => true %>
  <%= csrf_meta_tags %>
</head>
<body>

    <%= yield :application_navbar %>

<%= yield %>

</body>
</html>


// in layouts/search.html.erb

<% content_for :application_navbar do %>
    <%= render 'layouts/navbar' %>
<% end %>

<%= render template: "layouts/application" %>


// in search/index.html.erb

<% content_for :title do %>Home<% end %>
<h1>Welcome!</h1>
```

- Here, our controller will render `index.html.erb`. The `layouts/search.html.erb` will be its base. 
- IMPORTANT: The `render` block at the bottom of `layouts/search.html.erb` is what hooks up the `layouts/search.html.erb` file with the `layouts/application.html.erb` file.
- In `layouts/application.html.erb`, the `:title` comes from the `index` page, and the `:navbar` comes from the `search.html.erb` page.
