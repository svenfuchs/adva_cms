require File.dirname(__FILE__) + '/../spec_helper'

describe RolesHelper do
  include Stubby

  before :each do
    scenario :roles
  end

  describe "#role_to_default_css_class" do
    it "returns the role's name if no context is given" do
      helper.role_to_default_css_class(@user_role).should == 'user'
    end

    it "returns the role's context and name if context is given" do
      helper.role_to_default_css_class(@moderator_role).should == 'section-1-moderator'
    end
  end

  describe "#role_to_css_class" do
    it "returns 'anonymous' for an anonymous role" do
      helper.role_to_css_class(@anonymous_role).should == 'anonymous'
    end

    it "returns 'user' for a user role" do
      helper.role_to_css_class(@user_role).should == 'user'
    end

    it "returns 'user-1 content-1-author' for an author role when the author is a user" do
      helper.role_to_css_class(@author_role).should == 'user-1 content-1-author'
    end

    it "returns 'anonymous-1 content-1-author' for an author role when the author is an anonymous" do
      @content.should_receive(:author_type).and_return('Anonymous')
      helper.role_to_css_class(@author_role).should == 'anonymous-1 content-1-author'
    end

    it "returns 'section-1-moderator' for a user role" do
      helper.role_to_css_class(@moderator_role).should == 'section-1-moderator'
    end

    it "returns 'site-1-admin' for a admin role" do
      helper.role_to_css_class(@admin_role).should == 'site-1-admin'
    end

    it "returns 'superuser' for a superuser role" do
      helper.role_to_css_class(@superuser_role).should == 'superuser'
    end
  end

  describe '#authorize_elements' do
    it "returns a javascript tag that executes /user/[uid]/roles.js"
  end

  describe "#authorized_link_to" do
    before :each do
      helper.stub!(:add_authorizing_css_classes!)
      helper.stub!(:link_to)
    end

    it "adds authorizing css classes to the :class option" do
      helper.should_receive(:add_authorizing_css_classes!)
      helper.authorized_link_to('text', 'url', :update, Object.new)
    end

    it "delegates to link_to" do
      helper.should_receive(:link_to).with 'text', 'url', {}
      helper.authorized_link_to('text', 'url', :update, Object.new)
    end
  end

  describe '#add_authorizing_css_classes' do
    it "adds css classes that allow a user to see an element to the given options"
  end

  describe '#authorizing_css_classes' do
    before :each do
      @role = Rbac::Role.build :superuser
    end

    it "turns the given roles to css classes that allow a user to see an element" do
      helper.authorizing_css_classes([@role]).should == 'superuser'
    end

    it "given the option :quote it encloses the classes in single quotes" do
      helper.authorizing_css_classes([@role], {:quote => true}).should == "'superuser'"
    end

    it "given the option :separator it joins the classes using it" do
      helper.authorizing_css_classes([@role, @role], {:separator => ','}).should == "superuser,superuser"
    end
  end
end