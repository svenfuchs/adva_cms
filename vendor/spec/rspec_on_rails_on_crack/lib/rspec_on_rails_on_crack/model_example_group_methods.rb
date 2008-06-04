module Spec::Extensions::Main
  def describe_validations_for(model, attributes, &block)
    describe model, "(validations)", :type => :model do
      before :all do
        @attributes = attributes
      end
      
      before do
        @record = model.new
      end
      
      RspecOnRailsOnCrack::ValidationExampleProxy.new(self, model).instance_eval(&block)
    end
  end
end

module RspecOnRailsOnCrack
  class ValidationExampleProxy
    def initialize(example_group, model)
      @example_group, @model = example_group, model
    end

    def presence_of(*attributes)
      @example_group.it_validates_presence_of(@model, *attributes)
    end
    
    def uniqueness_of(*attributes)
      @example_group.it_validates_uniqueness_of(@model, *attributes)
    end
  end
end

module RspecOnRailsOnCrack
  module ModelExampleGroupMethods
    def self.extended(base)
      base.send :include, InstanceMethods
    end
    
    module InstanceMethods
      def create_record_from_attributes
        @record = @record.class.new
        @attributes.each do |key, value|
          @record.send("#{key}=", value)
        end
      end
    end
    
    #
    #   it_validates_presence_of Foo, :name
    #
    def it_validates_presence_of(model, *attributes)
      it "validates presence of: #{attributes.to_sentence}" do
        errors =
          attributes.collect do |attr|
            create_record_from_attributes
            
            next "Invalid with default attributes: #{@record.errors.full_messages.to_sentence}" unless @record.valid?
            
            old_value = @record.send(attr)
            @record.send("#{attr}=", nil)

            @record.valid? ? "Valid with @record.#{attr} == nil" : nil
          end.compact
        violated "Errors: #{errors.to_sentence}" unless errors.empty?
      end
    end
    
    #
    #   it_validates_uniqueness_of Foo, :name
    #
    def it_validates_uniqueness_of(model, *attributes)
      it "validates uniqueness of: #{attributes.to_sentence}" do
        errors =
          attributes.collect do |attr|
            create_record_from_attributes
            @record.save
            next "Invalid with default attributes: #{@record.errors.full_messages.to_sentence}" if @record.new_record?
            
            create_record_from_attributes
            
            @record.valid? || @record.errors.on(attr).nil? ? "Valid with duplicate @record.#{attr}" : nil
          end.compact
        violated "Errors: #{errors.to_sentence}" unless errors.empty?
      end
    end
  end
end