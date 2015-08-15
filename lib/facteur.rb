require "facteur/version"
require 'facteur/factory'

module Facteur
  def self.included(host_class)
    host_class.extend ClassMethods
  end

  class Factory
    attr_reader :name, :opts, :block
    def initialize(name, opts={}, &block)
      @name, @opts, @block = name, opts, block
    end

    def build(*args)
      Object.const_get(capitalized_name).new(*args)
    end

    private

    def capitalized_name
      @capitalized_name ||= name.to_s.capitalize
    end

    class Trait
      attr_reader :traits, :factories_dictionary
      def initialize(factories_dictionary, traits_dictionary, *traits)
        @factories_dictionary= factories_dictionary
        @traits = *traits
        @traits_dictionary = traits_dictionary
      end

      def build(name, *args)
        factory = factories_dictionary.fetch(name.to_sym)
        object = factory.build(*args)
        @traits_dictionary.each do |trait, block|
          next unless traits.include? trait
          block.call(object)
        end
        object
      end
    end
  end

  module ClassMethods
    def factory(name, opts = {}, &block)
      factories_dictionary[name.to_sym] = Factory.new(name, opts, &block)
    end

    def trait(name, &block)
      traits_dictionary[name.to_sym] = block
    end

    def factories_dictionary
      @factories_dictionary ||= Hash.new
    end

    def traits_dictionary
      @traits_dictionary ||= Hash.new
    end

    def build(name, *args)
      factory = factories_dictionary.fetch(name)
      factory.build(*args)
    end

    def traits(*names)
      Factory::Trait.new(factories_dictionary, traits_dictionary, *names)
    end
  end
end
