require File.dirname(__FILE__) + '/../spec_helper'

describe Site do
  fixtures :sites, :sections
  
  before :each do 
    @site = sites(:site_1)
    @home = sections(:home)
    @about = sections(:about)
    @location = sections(:location)
  end
  
  describe "site.sections.update_paths!" do
    it "updates all paths" do
      sections = [@home, @about, @location]
      sections.each do |section|      
        section.path = nil
        section.save!
      end
      @site.sections.update_paths!
      sections.map(&:reload)
      sections.collect(&:path).should == ['home', 'home/about', 'home/about/location']
    end
  end
  
  describe 'associations:' do
    it "should have complete specs"
    # TODO implement: it_should_have_many :sections, :dependent => :destroy
    it "has many sections" do 
      @site.should have_many(:sections) 
    end
  
    it "has many users" do 
      @site.should have_many(:users)
    end
  
    it "has many assets" do 
      @site.should have_many(:assets)
    end
  
    it "has many cached_pages" do 
      @site.should have_many(:cached_pages)
    end
  
    it "the sections association returns the left-most section that has no parent as the root section" do
      @site.sections.root.should == @home
    end
  end
  
  it "calls destroy! on associated users when destroyed" do
    user = @site.users.create :name => 'user', :email => 'email@foo.bar', :login => 'login', :password => 'password', :password_confirmation => 'password'
    user.should_not be_false
    @site.destroy
    lambda{ User.find_with_deleted user.id }.should raise_error(ActiveRecord::RecordNotFound)
  end  
  
end