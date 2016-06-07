# Helpers

### When to use helpers
- http://stackoverflow.com/questions/5019794/when-to-use-helpers-vs-model
- It's best to use helpers when the code that the helper is creating is meant to be displayed in the view only. For example if you want to have methods that help create HTML links, they should go in the helper:
- Example
```
def easy_link user
  link_to(user.name, user)
end
```
- If your code is business logic it should go in your models. You should also aim to put as much business logic in your models, you don't want this code in your views and controllers. i.e. Fat models, skinny controllers!