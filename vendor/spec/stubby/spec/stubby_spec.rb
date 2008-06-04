require File.dirname(__FILE__) + "/spec_helper"

module ActiveRecord
  class Base 
    attr_accessor :id
    def has_attribute?(name)
      false
    end
    def inspect
      "<#{self.class.name}:#{object_id}>"
    end
  end 
end

class Site < ActiveRecord::Base; end
class Section < ActiveRecord::Base; end
class User < ActiveRecord::Base; end
class ApiKey < ActiveRecord::Base; end

Stubby::Loader.load

describe "Stubby" do
  include Stubby

  before :each do
    scenario :site
  end
  
  describe "base class creation" do
    it "creates a class Stubby::Classes::Site" do
      lambda{ Stubby::Classes::Site }.should_not raise_error
    end
    
    it "creates a class Stubby::Classes::Section" do
      lambda{ Stubby::Classes::Section }.should_not raise_error
    end
    
    describe "an instance of the site base class" do
      it "responds to :save" do
        Stubby::Classes::Site.new.should respond_to(:save)
      end
      
      it "responds to :destroy" do
        Stubby::Classes::Site.new.should respond_to(:destroy)
      end
      
      it "responds to :active?" do
        Stubby::Classes::Site.new.should respond_to(:active?)
      end
      
      it "responds to :sections" do
        Stubby::Classes::Site.new.should respond_to(:sections)
      end
      
      it "responds to :user" do
        Stubby::Classes::Site.new.should respond_to(:user)
      end
      
      it "responds to :api_key" do
        Stubby::Classes::Site.new.should respond_to(:api_key)
      end
    end
  end
  
  describe "instance class creation" do
    it "creates a class Stubby::Classes::Site::Site" do
      lambda{ Stubby::Classes::Site::Site }.should_not raise_error
    end
  
    it "creates a class Stubby::Classes::Section::Root" do
      lambda{ Stubby::Classes::Section::Root }.should_not raise_error
    end
    
    describe "an instance of the site instance class" do
      it "responds to :save (as inherited from its base class)" do
        Stubby::Classes::Site::Site.new.should respond_to(:save)
      end
  
      it "responds to :name" do
        Stubby::Classes::Site::Site.new.should respond_to(:name)
      end
    end
  end
  
  describe "stub lookup" do
    describe "with a singular lookup method" do
      it "returns the first defined stub if no key is given" do
        stub_site.name.should == 'site'
      end
    
      it "returns the stub referenced by a given key" do
        stub_site(:another).name.should == 'another'
      end
    
      it "returns a collection of all stubs when :all is given as a key" do
        stub_site(:all).should == [stub_site, stub_site(:another)]
      end    
    end
    
    describe "with a plural lookup method" do
      it "returns an array containing all stubs when no key is given" do
        sites = stub_sites
        sites.size.should == 2
        sites.should == [stub_site, stub_site(:another)]
      end
          
      it "returns an array containing all stubs when :all is given as a key" do
        sites = stub_sites(:all)
        sites.size.should == 2
        sites.should == [stub_site, stub_site(:another)]
      end
          
      it "returns an array containing the referenced stub when a key is given" do
        sites = stub_sites(:another)
        sites.size.should == 1
        sites.should == [stub_site(:another)]
      end
      
      it "returns an array containing all stubs even when a single stub has been looked up before" do
        stub_site
        sites = stub_sites(:all)
        sites.size.should == 2
        sites.should == [stub_site, stub_site(:another)]
      end
    end
    
  end
  
  describe "a has_many_proxy" do                                                
    it "responds to :find" do
      @site.sections.respond_to?(:find).should be_true
    end
  
    it "its find method returns an array of stub instance masquerading as a Site instance" do
      @site.sections.find.should == stub_section
    end
  
    it "its target is an array of stub instances masquerading as a Site instance" do
      @site.sections.should == stub_sections
    end
  
    it "works with rspec mock expectations" do
      @site.sections.should_receive(:foo)
      @site.sections.foo
    end
  end
  
  describe "a method on a stub" do
    before :each do
      @another = stub_site(:another)
    end
    
    it "returns the same stub during one spec" do
      @site.next.object_id.should == @another.object_id
      @site.next.object_id.should == @another.object_id
    end
    
    previous_object_id = nil
    1.upto(2) do # what's a less brittle way to spec something like this?
      it "returns a new stub for each spec" do
        previous_object_id.should_not == @site.next.object_id
        previous_object_id = @site.next.object_id
      end
    end
  end
  
  describe "a method on a HasManyProxy" do
    before :each do
      @section = stub_section
    end
    
    it "returns the same stub during one spec" do
      @site.sections.find.object_id.should == @section.object_id
      @site.sections.find.object_id.should == @section.object_id
    end
    
    previous_object_id = nil
    1.upto(2) do # what's a less brittle way to spec something like this?
      it "returns a new stub for each spec" do
        previous_object_id.should_not == @site.sections.find.object_id
        previous_object_id = @site.sections.find.object_id
      end
    end
  end
  
  describe "a HasManyProxy's content" do
    before :each do
      @section = stub_section
    end
    
    it "returns the same stub during one spec" do
      @site.sections.first.object_id.should == @section.object_id
      @site.sections.first.object_id.should == @section.object_id
    end
    
    previous_object_id = nil
    1.upto(2) do # what's a less brittle way to spec something like this?
      it "returns a new stub for each spec" do
        previous_object_id.should_not == @site.sections.first.object_id
        previous_object_id = @site.sections.first.object_id
      end
    end
  end

end