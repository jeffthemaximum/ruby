# Adding materialize (or similar js/css framework)

 - app/assets are custom js/img/css that apply to the application
 - lib/assets are assets that don't fit into the scope of the app and are shared across the whole project
 - vendor/assets are third party assets, such as materialize.

----------

 - materialize.js will go in `vendor/assets/javascripts`
 - materialize.css will go in `vendor/assets/stylesheets`
 - `fonts` are tricky. Put them in `app/assets/fonts` and application pipeline will find them. However, if they have hyphens, you're screwed. Try removing the hyphens from the file names and from the css/scss that refers to those fonts.

