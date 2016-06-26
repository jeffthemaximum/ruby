# Users - Big Picture

- One thing I've learned form web development in Flask, Django, and at Byte Academy is that there's rarely a good reason to write your own User model.

- Michael Hartl says, ""For one, practical experience shows that authentication on most sites requires extensive customization, and modifying a third-party product is often more work than writing the system from scratch."

- So, I don't want to user a 3rd party User gem, and I don't want to try to invent a User model myself.

- This is why I chose to use the User model from https://www.railstutorial.org/book/modeling_users

- His user system is one that's based on best-practices and battle-tested lesson from major sites, such as Twitter, and it's also one that's custom made by me.

- This means I won't make any mistakes around passwords, hashing, testing, etc., but I'll still have a system I can work within and customize if I want to. 

# Users

- Basically, I followed MH's tutorial here in chapters 6, 7, 8, 9, and 10.
- I'll document the changes I've made below...

# Changes

### Testing

- MH uses Rails test framework. I used Rspec and custom wrote all the tests myself. This is for two reasons.

- First, Experiment uses Rspec, and I wanted to use the testing framework I'll use on the job.

- Second, it'll force me to think through the tests, as I can't just copy paste his code.

- The learned I did with Rspec is documented in a seperate repo, here: https://github.com/jeffthemaximum/ruby/tree/master/rails/testing

