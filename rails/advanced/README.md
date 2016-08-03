# Advanced Rails stuffs

- This is stuff that doesn't have it's own folder in my repo yet
- But still is pretty important and I wanted to take notes aboot

# Services

### Basics

- https://blog.engineyard.com/2014/keeping-your-rails-controllers-dry-with-services
- https://www.netguru.co/blog/service-objects-in-rails-will-help
- Helps keep controllers skinny and also prevents overfattening models

### Where we use them in spearmint

- app/services

### How we use them in spearmint

- An example is `ProjectPayoutService`
- This service lives in `app/services/project_payout_service.rb1
- this file contained `class ProjectPayoutService` with has an `def initialize`, `def self.call`, and `def call` methods.
- `def self.call` lets us do `ProjectPayoutService.call(self, params.funds)` on line 1001 of `app/models/project.rb`
- Benefits
  - keeps project payout logic out of model and view
  - lets us reuse this logic anywhere in app

# Concerns

### Basics

- http://stackoverflow.com/a/25858075
- Concerns are essentially modules that allow you to encapsulate model roles into separate files to DRY up your code.
- to skin-nize fat models as well as DRY up your model codes

### Where we use them in spearmint

- `app/models/concerns`

### How we use them in spearmint

- 

# Module / Class

# Include

# Extend

# `class_name` in models

# `table_name_prefix`

# policies

# interactor

# presentators