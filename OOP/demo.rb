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