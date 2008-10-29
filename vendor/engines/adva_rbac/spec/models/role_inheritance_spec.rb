require File.dirname(__FILE__) + '/../spec_helper'

describe Rbac::Role, ".define", :type => :rbac do
  it "creates a new Role class in the Rbac::Role namespace" do
    Rbac::Role.define :admin
    Rbac::Role.const_defined?('Admin').should be_true
  end

  it "inherits the new Role class from Rbac::Role::Base if no parent option is given" do
    Rbac::Role.define :admin
    Rbac::Role::Admin.parent.should == Rbac::Role::Base
  end

  it "inherits the new Role class according to the given parent option" do
    Rbac::Role.define :moderator
    Rbac::Role.define :admin, :parent => :moderator
    Rbac::Role::Admin.parent.should == Rbac::Role::Moderator
  end
end

describe Rbac::Role, ".build", :type => :rbac do
  before :each do
    Rbac::Role.define :moderator, :require_context => Section
    Rbac::Role.define :admin, :require_context => Site, :parent => :moderator
  end

  it "instantiates a role with the given type" do
    @role = Rbac::Role.build :admin, :context => @site
    @role.should be_instance_of(Rbac::Role::Admin)
  end

  it "adjusts the given context to fit the required context type of the role" do
    @role = Rbac::Role.build :admin, :context => @content
    @role.context.should == @site
  end
end

describe Rbac::Role, "#adjust_context", :type => :rbac do
  before :each do
    Rbac::Role.define :user
    Rbac::Role.define :moderator, :require_context => Section, :parent => :user
    Rbac::Role.define :admin, :require_context => Site, :parent => :moderator
  end

  it "returns the given context if require_context is not set" do
    @role = Rbac::Role.build :user, :context => @site
    @role.send(:adjust_context, @site).should == @site
  end

  it "returns the given context if it has the same type as require_context" do
    @role = Rbac::Role.build :admin, :context => @site
    @role.send(:adjust_context, @site).should == @site
  end

  it "returns the given context's parent context which has the same type as require_context" do
    @role = Rbac::Role.build :admin, :context => @content
    @role.send(:adjust_context, @content).should == @site
  end

  it "returns the given context if it is a child type of the require_context" do
    @role = Rbac::Role.build :moderator, :context => @site
    @role.send(:adjust_context, @site).should == @site
  end
end

describe Rbac::Role, "#include?", :type => :rbac do
  before :each do
    Rbac::Role.define :user
    Rbac::Role.define :author, :require_context => Content, :parent => :user,
                      :grant => lambda{|context, user| context && !!context.subject.try(:is_author?, user) }
    Rbac::Role.define :moderator, :require_context => Section, :parent => :author
    Rbac::Role.define :admin, :require_context => Site, :parent => :moderator
  end

  it "is true for Author(:context => content).include? User" do
    @content.stub!(:is_author?).and_return true
    Rbac::Role.build(:author, :context => @content).should include_role(:user)
  end
  
  it "is true for Admin(:context => site).include? User" do
    Rbac::Role.build(:admin, :context => @site).should include_role(:user)
  end

  it "is true for Moderator(:context => site).include? Moderator(:context => site)" do
    Rbac::Role.build(:moderator, :context => @site).should include_role(:moderator, :context => @site)
  end

  it "is true for Moderator(:context => site).include? Moderator(:context => site.content)" do
    Rbac::Role.build(:moderator, :context => @site).should include_role(:moderator, :context => @content)
  end
  
  it "is true for Admin(:context => site).include? Moderator(:context => site)" do
    Rbac::Role.build(:admin, :context => @site).should include_role(:moderator, :context => @site)
  end
  
  it "is true for Admin(:context => site).include? Moderator(:context => site.content)" do
    Rbac::Role.build(:admin, :context => @site).should include_role(:moderator, :context => @content)
  end
  
  it "is false for Moderator(:context => site.content).include? Moderator(:context => site)" do
    Rbac::Role.build(:moderator, :context => @content).should_not include_role(:moderator, :context => @site)
  end
  
  it "is false for Moderator(:context => site).include? Admin(:context => site)" do
    Rbac::Role.build(:moderator, :context => @site).should_not include_role(:admin, :context => @site)
  end
  
  it "is false for Admin(:context => site).include? Admin(:context => other_site)" do
    Rbac::Role.build(:admin, :context => @site).should_not include_role(:moderator, :context => @other_site)
  end
  
  it "is false for Admin(:context => site).include? Admin(:context => other_site.content)" do
    Rbac::Role.build(:admin, :context => @site).should_not include_role(:moderator, :context => @other_content)
  end
end
