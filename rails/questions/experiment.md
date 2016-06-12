# UserMailer

- **How does rails handle async tasks?**

- It seems like sending async emails is pretty straightforward, as shown in example below. Is this true for other async tasks? Can we use this for DB writes?

- in models/user.rb, on line 307

```
def send_registration_confirmation_email
    UserMailer.registration_confirmation(id).deliver(delay: 0)
end
```
- and, in models/user.rb on line 286

```
  def send_password_reset
    UserMailer.password_reset(id).deliver(async: false)
  end
```
