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

# bang bang

- example:
```
  def signed_in?
    !!current_user
  end
```
`!` converts the value to a boolean, and gives the opposite. So, the purpose of `!!` is to return a boolean value about the presence/absence of a value.

# Assignment

- Crazyness!

```
>> a = b = 3
>> a
=> 3
>> b
=> 3
```