# Modules

- A `module` in ruby is a namespace.
- from https://rubymonk.com/learning/books/1-ruby-primer/chapters/35-modules/lessons/80-modules-as-namespaces

```
module Perimeter
  class Array
    def initialize
      @size = 400
    end
  end
end

our_array = Perimeter::Array.new
ruby_array = Array.new

p our_array.class
p ruby_array.class
```

- The benefit here is that we can create an `Array` class that won't conflict with ruby's `Array` class.
- We refer to the `Array` class be declared as `Perimeter::Array`, while we refer to ruby's as `Array`.

# Constant lookup

- Notice the `::` ... this is how you reference the `class` that's within the `module`.
- You can use this on anything that's within a module, not just classes.
- from https://rubymonk.com/learning/books/1-ruby-primer/chapters/35-modules/lessons/80-modules-as-namespaces

```
module Dojo
  A = 4
  module Kata
    B = 8
    module Roulette
      class ScopeIn
        def push
          15
        end
      end
    end
  end
end

A = 16
B = 23
C = 42

puts "A - #{A}"
puts "Dojo::A - #{Dojo::A}"

puts

puts "B - #{B}"
puts "Dojo::Kata::B - #{Dojo::Kata::B}"

puts

puts "C - #{C}"
puts "Dojo::Kata::Roulette::ScopeIn.new.push - 
```

- This tells us two important things. One, we can nest constant lookups as deep as we want. Second, we aren't restricted to just classes and modules.

# include / included

- module can be included into other classes so that the module's methods are available to instances of that class.
- In order to include a module into a class, we use the method include which takes one parameter - the name of a Module.
- basic example

```
module WarmUp
  def push_ups
    "Phew, I need a break!"
  end
end

class Gym
  include WarmUp
  
  def preacher_curls
    "I'm building my biceps."
  end
end

class Dojo
  include WarmUp
  
  def tai_kyo_kyu
    "Look at my stance!"
  end
end

puts Gym.new.push_ups
puts Dojo.new.push_ups
```

- 