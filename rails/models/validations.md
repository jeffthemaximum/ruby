# Validations

### Validating prescence of a field

- Set the model like so:
```
class User < ActiveRecord::Base
  validates(:name, presence: true)
end
```

### Validating length

- Get the models like so:

```
class User < ActiveRecord::Base
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true
end
```
- Here, the `length: { maximum: 50 }` sets the maximum length of a name column on a User object.

### Validating format

- woefn

# Checking error messages

- Say we have a model like this:
```
class User < ActiveRecord::Base
  validates(:name, presence: true)
end
```

- And then we do this code:
```
user = User.new(name: "", email: "mhartl@example.com")
```

- Out user should be invalid. To test this, we do
```
user.valid?
```

- And we get `False`. So, to get the error messages, we do:
```
user.errors.full_messages
=> ["Name can't be blank"]
```

