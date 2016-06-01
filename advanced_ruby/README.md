# Lambdas
Anonymous functions with Ruby. 

example:
```
foo = lambda { "hello" }
foo.call
```

You need to use .call to execute it.

Anonymous functions with parameters:
```
foo = lambda do |str|
    baz = 'jeff'
    x = 2
    puts x
    str + " " + baz
end

foo.call('I am')
```
The convention is to use `{}` with single line lambda and `do...end` with multiline lambda's. 