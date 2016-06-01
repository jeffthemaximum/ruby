#Basics
```
 class Animal
    attr_accessor :kind, :name

    def initialize(kind, name)
        @kind = kind
        @name = name
    end

    def to_s
        @name
    end
end

cat = Animal.new("cat", "mickey")

puts cat
```

attr_accessor lets you access with cat.name or cat.kind

`to_s` is the equivalent of `__repr__` in python, except it doesn't get invoked automatically.

#Extending a class
```
module AnimalSayer
    def say
        "meow"
    end
end

cat.extend(AnimalSayer)
```
Or, just continue the Class. So, if you've already declared the Animal class, later, you can:
```
class Animal
    def hello
        puts "hello"
    end
end
```