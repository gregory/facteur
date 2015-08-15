require 'spec_helper'

describe Facteur do
  let(:factory_name) { :foo }
  let(:params) { { foo: :bar } }
  let(:block) { ->(*) {} }
  let(:capitalized_name) { factory_name.to_s.capitalize }
  let(:trait_name) { :foo_trait }
  let(:target_class) { Class.new }
  let(:host_class) do
    Class.new do
      include Facteur
    end
  end

  before do
    Object.const_set(capitalized_name, target_class) unless defined? Foo
  end

  describe '.factory(name, opts={})' do
    subject { host_class.factories_dictionary[factory_name] }

    before { host_class.send(:factory, factory_name, params, &block) }

    it 'defines a factory' do
      expect(subject).to be_instance_of Facteur::Factory
      expect(subject.name).to eq factory_name
      expect(subject.opts).to eq params
      expect(subject.block).to eq block
    end
  end

  describe '.trait(name, &block)' do
    subject { host_class.traits_dictionary[trait_name] }

    before { host_class.send(:trait, trait_name, &block) }

    it 'defines a factory' do
      expect(subject).to eq block
    end
  end

  describe '.build(args)' do
    before { host_class.send(:factory, factory_name, params, &block) }

    subject { host_class.build(factory_name) }

    it 'returns the class associated to the name' do
      expect(subject).to be_an_instance_of Foo
    end
  end

  describe 'traits(*names)' do
    let(:listener) { double(:block)}
    let(:listener_method) { :foo }
    let(:block) { ->(obj) { listener.send(listener_method, obj) } }
    subject { host_class.traits(trait_name).build(factory_name) }
    before do
      host_class.send(:trait, trait_name, &block)
      host_class.send(:factory, factory_name, params, &block)
    end

    it 'returns the class associated to the name' do
      expect(listener).to receive(listener_method)
      expect(subject).to be_instance_of Foo
    end
  end
end
