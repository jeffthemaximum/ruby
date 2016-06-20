# Validating presence of a field

- Set the model like so:
```
class User < ActiveRecord::Base
  validates(:name, presence: true)
end
```

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

