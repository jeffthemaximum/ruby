# Mailer

- As of 6/12/2016, I've only seen these in the Experiment-prod site, haven't read any tutorials, so this may or may not be best practice.

#### Where mailer classes go

- Seems like they go into the `app/` directory, in a `mailer/` directory that's at the level of `controllers`, `models`, etc.

#### How to create a mailer

- There may be a generator for this, but I don't know if there is yet.

- Create a class that inherits from Mailer, example below:

```
class UserMailer < Mailer
end
```

- Then, create a method within this new, custom mailer class, see example below:

```
class UserMailer < Mailer
  layout 'experiment_mailer_in_row', except: [:feedback_received]

  def registration_confirmation(user_id)
    @user = User.find user_id

    # Don't send registration_confirmation if user has already donated
    # They've have already got the payment_confirmation email
    # See #3052
    return if @user.payments.any?

    mail to: @user, subject: 'Welcome to Experiment!'
  end
end
```

- Then, call that new method you've made from other places in your Rails app. No imports or requires seem to be necessary to get these into the file from which you call it.

- For example, the code below will live in `app/models/user.rb` but will call the mailer from `app/mailers/user_mailer.rb`:

```
def send_registration_confirmation_email
UserMailer.registration_confirmation(id).deliver(delay: 0)
end
```

- And, since this is a method on the `User` class, you could call this method from within the controller by doing something like `user.send_registration_confirmation_email`
