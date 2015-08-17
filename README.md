# Facteur: minimalist gem for application Factories

By using a factory class to build objects, we have a single place that has a single responsability that encapsulate the business logic around the object construction.

## Problem

```rb
class Person < ActiveRecord::Base
  def self.build_employee(data); end
  def self.create_employee(data); end
  def self.build_employee_with_store(data); end
  def self.create_employee_with_store(data); end
  def self.build_manager(data); end
  def self.create_manager(data); end
  def self.build_manager_with_store(data); end
  def self.create_manager_with_store(data); end
end
```

Here is the structure of the methods: `[persistance, type of object, features]`

* We can see that the number of methods could easily grow exponentially with the number of variations/traits of the creation of a person.
* Implemtation of those methods would lead to a lots of redundant code.
* We mix the persistance layer (ActiveRecord) with the business layer (logic to apply to create those objectst)
* Testing would involve loading the framework thus the all environment (rails would be needed since we are inherit active_record here)

## Solution: decoration by composition

We need to find a way to build then decorate an object.
In our example, a manager will have `management` feature that an employee wont have.
Ie: A manager will have the management feature
A `trait` will be a group of features.

## Usage
```rb
  class Person < ActiveRecord::Base; end
  class Manager < Person; ActiveRecord::base; end

  person = PersonFactory.build(params)
  employee = PersonFactory.build(:employee, params)
  manager  = PersonFactory.build(:manager, params)

  # that was easy, now let's build a new employee with a couple features:
  employee = PersonFactory.traits(:management, :with_store).build(:employee, params)

  # In some cases, you might still want some custom decoration strategies.
  manager = PersonFactory.build(:manager, params) do | person_factory|
    # In this example, we need to pass in some specific params
    person_factory.with_feature_a(feature_a_params)
    person_factory.with_store
  end

  # Sometimes we may also want to let the factory decide what to return:
  PersonFactory.custom(:special_employee).traits(:management, :store).build(params)
```

## Usage

```rb
  class PersonFactory
    include Factory
    factory :employee, class: Person, traits: [:coding]
    factory :manager, traits: [:management, :skateboarding]
    factory :employee_with_store, class: Person do |person_factory|
      person_factory.with_store
    end

    trait :coding do |object|
    end

    trait :management do |object|
    end

    trait :skateboarding do |object|
    end

    def with_store
      object.store = StoreFactory.create(params)
      self
    end

    def with_feature_a(feature_a_params); end

    def self.custom(type)
      case type
      when :manager
        new(:manager)
      when :special_employee
        factory = new(:manager).with_store
        Time.noon? ? factory.traits(:skateboarding) : factory
      end
    end
  end
```

## conclusion

With this approach, code is reusable, behaviour is isolated, the single responsability of the factory is to return a new object.
We do not mix in any framework component thus don't need to load any extra libs to test the factory.

I haven't shared the implementation since i want this to be readme driven development :)
Feel free to share your thoughts!
TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'facteur'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install facteur

## Contributing

1. Fork it ( https://github.com/[my-github-username]/facteur/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
