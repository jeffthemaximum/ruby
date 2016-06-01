# lambda
foo = lambda { "hello" }
foo.call

# lambda with params
foo = lambda do |str|
    baz = 'jeff'
    x = 2
    puts x
    str + " " + baz
end

foo.call('I am')