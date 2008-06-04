require File.dirname(__FILE__) + '/spec_helper'

module NoPeepingTomsSpec
  class Person < ActiveRecord::Base; end
  
  class PersonObserver < ActiveRecord::Observer
    def before_update(person)
      $observer_called_names.push person.name
    end
  end
  
  class AnotherObserver < ActiveRecord::Observer
    observe Person
    def before_update(person)
      $calls_to_another_observer += 1
    end
  end
  
  describe Person, " when changing a name" do
    before(:each) do
      $observer_called_names = []
      $calls_to_another_observer = 0
      @person = Person.create! :name => "Pat Maddox"
    end

    it "should not register a name change" do
      @person.update_attribute :name, "Name change"
      $observer_called_names.pop.should be_blank
      $calls_to_another_observer.should == 0
    end

    it "should register a name change with the person observer turned on" do
      Person.with_observers("NoPeepingTomsSpec::PersonObserver") do
        @person.update_attribute :name, "Name change"
        $observer_called_names.pop.should == "Name change"
      end

      @person.update_attribute :name, "Man Without a Name"
      $observer_called_names.pop.should be_blank
      
      $calls_to_another_observer.should == 0
    end
    
    it "should handle multiple observers" do
      Person.with_observers("NoPeepingTomsSpec::PersonObserver", "NoPeepingTomsSpec::AnotherObserver") do
        @person.update_attribute :name, "Name change"
        $observer_called_names.pop.should == "Name change"
      end

      @person.update_attribute :name, "Man Without a Name"
      $observer_called_names.pop.should be_blank
      
      $calls_to_another_observer.should == 1
    end
  end
end
