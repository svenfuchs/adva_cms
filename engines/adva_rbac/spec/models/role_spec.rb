require File.dirname(__FILE__) + '/../spec_helper'

describe Rbac::Role::Base, :type => :rbac do
  include SpecRolesHelper
  
  before :each do
    define_roles!
  end
  
  it "can save to the database" do
    Rbac::Role.build(:admin, :context => @site).save.should be_true
  end
  
  it "can load from the database" do
    Rbac::Role::Base.delete_all
    Rbac::Role::User.create :context => @site
    Rbac::Role::User.first.should be_instance_of(Rbac::Role::User)
  end
end

describe Rbac::Role, "#message", :type => :rbac do
  before :each do
    @message = 'You need to be logged in to perform this action.'
    Rbac::Role.define :user, :message => @message
  end
  
  it "returns the message defined for the role" do
    Rbac::Role.build(:user).message.should == @message
  end
end

describe Rbac::Role, "#role_name", :type => :rbac do
  before :each do
    Rbac::Role.define :user
  end
  
  it "returns the role name as a symbol" do
    Rbac::Role::User.role_name.should == :user
  end
end

describe Rbac::Role, '.all_children', :type => :rbac do
  include SpecRolesHelper
  
  before :each do
    define_roles!
  end
  
  describe "returns all the roles inheriting from the given role" do
    it "returns :anonymous, :user, :author, :moderator, :admin, :superuser classes for :base" do
      expected = [Rbac::Role::Anonymous, Rbac::Role::User, Rbac::Role::Author, Rbac::Role::Moderator, Rbac::Role::Admin, Rbac::Role::Superuser]
      Rbac::Role::Base.all_children.should == expected
    end

    it "returns :user, :author, :moderator, :admin, :superuser classes for :anonymous" do
      expected = [Rbac::Role::User, Rbac::Role::Author, Rbac::Role::Moderator, Rbac::Role::Admin, Rbac::Role::Superuser]
      Rbac::Role::Anonymous.all_children.should == expected
    end         

    it "returns :author, :moderator, :admin, :superuser classes for :user" do
      expected = [Rbac::Role::Author, Rbac::Role::Moderator, Rbac::Role::Admin, Rbac::Role::Superuser]
      Rbac::Role::User.all_children.should == expected
    end         

    it "returns :moderator, :admin, :superuser classes for :author" do
      expected = [Rbac::Role::Moderator, Rbac::Role::Admin, Rbac::Role::Superuser]
      Rbac::Role::Author.all_children.should == expected
    end         

    it "returns :admin, :superuser classes for :moderator" do
      expected = [Rbac::Role::Admin, Rbac::Role::Superuser]
      Rbac::Role::Moderator.all_children.should == expected
    end         

    it "returns the :superuser class for :admin" do
      expected = [Rbac::Role::Superuser]
      Rbac::Role::Admin.all_children.should == expected
    end         

    # it "returns :superuser classes for :owner" do
    #   expected = [Rbac::Role::Superuser]
    #   Rbac::Role::Owner.all_children.should == expected
    # end         

    it "returns no classes for :superuser" do
      expected = []
      Rbac::Role::Superuser.all_children.should == expected
    end
  end
end

describe Rbac::Role, '#expand', :type => :rbac do
  include SpecRolesHelper
  
  before :each do
    define_roles!
    @anonymous_role = Rbac::Role.build(:anonymous)
    @user_role      = Rbac::Role.build(:user)
    @author_role    = Rbac::Role.build(:author, :context => @content)
    @moderator_role = Rbac::Role.build(:moderator, :context => @section)
    @admin_role     = Rbac::Role.build(:admin, :context => @site)
    # @owner_role     = Rbac::Role.build(:owner, :context => @account)
    @superuser_role = Rbac::Role.build(:superuser)
  end
  
  it 'called on an anonymous role it returns itself, an user, an author, a moderator, an admin, an owner and a superuser role' do
    @anonymous_role.expand(@content).should == [@anonymous_role, @user_role, @author_role, @moderator_role, @admin_role, @superuser_role]
  end
  
  it 'called on an user role it returns itself, an author, a moderator, an admin, an owner and a superuser role' do
    @user_role.expand(@content).should == [@user_role, @author_role, @moderator_role, @admin_role, @superuser_role]
  end
  
  it 'called on an author role it returns itself, a moderator, an admin, an owner and a superuser role' do
    @author_role.expand(@content).should == [@author_role, @moderator_role, @admin_role, @superuser_role]
  end

  it 'called on a moderator role it returns itself, an admin, an owner and a superuser role' do
    @moderator_role.expand(@content).should == [@moderator_role, @admin_role, @superuser_role]
  end
    
  it 'called on an admin role it returns itself, an owner role and a superuser role' do
    @admin_role.expand(@content).should == [@admin_role, @superuser_role]
  end

  # it 'called on a owner role it returns itself, and a superuser role' do
  #   @owner_role.expand(@content).should == [Rbac::Role::Owner, @superuser_role]
  # end

  it 'called on a superuser role it returns only itself' do
    @superuser_role.expand(@content).should == [@superuser_role]
  end
end

describe Rbac::Role, "role_authorizing and expand return the expected results for css class generation", :type => :rbac do
  include SpecRolesHelper
  
  before :each do
    define_roles!
    Rbac::Context.permissions[:'edit content'] = :author
  end

  it "just works" do
    roles = @content.role_authorizing('edit content').expand(@content)
    role_descriptions(roles).should == ['content-author', 'section-moderator', 'site-admin', 'superuser']
  end
  
  def role_descriptions(roles)
    roles.map{|role| (role.context ? "#{role.context.class.name.downcase}-" : '') + role.class.role_name.to_s.downcase}
  end
end
=begin
=end
