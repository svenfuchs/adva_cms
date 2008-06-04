require File.dirname(__FILE__) + '/../spec_helper'


describe 'Roles: ' do
  include Stubby
  
  before :each do 
    @user = User.new
    @user.stub!(:id).and_return 2
    
    @site = Site.new
    @section = Section.new
    @section.stub!(:site).and_return @site
    
    @content = Content.new
    @content.stub!(:section).and_return @section
    @content.stub!(:author_id).and_return 1
    @content.stub!(:author_type).and_return 'User'

    @admin_role = Role.new :name => 'admin', :user => @user, :object => @site
    @moderator_role = Role.new :name => 'moderator', :user => @user, :object => @section
    @user_role = Role.new :name => 'user', :user => @user, :object => @site # nonsense, just for testing
    
  end
  
  { Role::Roles::User      => 'You need to be logged in to perform this action.',
    Role::Roles::Author    => 'You need to be the author of this object to perform this action.',
    Role::Roles::Moderator => 'You need to be a moderator to perform this action.',
    Role::Roles::Admin     => 'You need to be an admin to perform this action.',
    Role::Roles::Superuser => 'You need to be a superuser to perform this action.' }.each do |role, message|
  
    it "#{Role}#role_required_message returns '#{message}'" do
      role.role_required_message.should == message
    end
  end
  
  describe User do
    describe '#detect_role given :admin' do
      it "returns the user's admin role if he has one" do
        @user.stub!(:roles).and_return [@moderator_role, @user_role, @admin_role]
        @user.detect_role(:admin, @site).should == @admin_role
      end
    
      it "returns nil if he does not have an admin role" do
        @user.stub!(:roles).and_return [@moderator_role, @user_role]
        @user.detect_role(:admin, @site).should be_nil
      end
    end
  
    describe '#has_role?' do  
      it "delegates to the passed object's #has_user_role? when given" do
        @site.should_receive(:user_has_role?)
        @user.has_role?(:admin, @site)
      end
    
      it 'delegates to #detect_role when no object is given' do
        @user.should_receive(:detect_role)
        @user.has_role?(:admin)
      end
    end
  end
  
  describe Site do
    describe '#user_has_role?' do  
      describe 'with @user, :admin passed' do
        it 'yields true if the user has an admin role for this site' do
          @user.stub!(:roles).and_return [@moderator_role, @user_role, @admin_role]
          @site.user_has_role?(@user, :admin).should be_true
        end  
      
        it 'yields false if the user does not have an appropriate role' do
          @user.stub!(:roles).and_return [@moderator_role, @user_role]
          @site.user_has_role?(@user, :admin).should be_false
        end  
      end
      
      describe 'with @user, :moderator passed' do
        it "yields true if the user has an admin role for the site" do
          @user.stub!(:roles).and_return [@admin_role]
          @site.user_has_role?(@user, :moderator).should be_true
        end  
      
        it 'yields false if the user does not have an appropriate role' do
          @user.stub!(:roles).and_return [@user_role]
          @site.user_has_role?(@user, :moderator).should be_false
        end  
      end
    end
  end
  
  describe Section do
    describe '#user_has_role?' do  
      describe 'with @user, :moderator passed' do
        it 'yields true if the user has a moderator role for this section' do
          @user.stub!(:roles).and_return [@moderator_role]
          @section.user_has_role?(@user, :moderator).should be_true
        end  
        
        it "yields true if the user has an admin role for the section's site" do
          @user.stub!(:roles).and_return [@admin_role]
          @section.user_has_role?(@user, :moderator).should be_true
        end  
      
        it 'yields false if the user does not have an appropriate role' do
          @user.stub!(:roles).and_return [@user_role]
          @section.user_has_role?(@user, :moderator).should be_false
        end  
      end
    end
    
    describe "#default_required_roles" do
      it 'returns a hash of default role mappings' do
        Section.default_required_roles[:manage_articles].should == :admin
      end
    end
    
    describe "#required_roles" do
      it 'returns an the default_required_roles for a new_record' do
        Section.new.required_roles.should == { :manage_articles => :admin }
      end
    end
  end
  
  describe Content do
    describe '#user_has_role?' do  
      describe 'with @user, :admin passed' do
        it "yields true if the user has an admin role for the content's site" do
          @user.stub!(:roles).and_return [@admin_role]
          @content.user_has_role?(@user, :admin).should be_true
        end
      
        it 'yields false if the user does not have an appropriate role' do
          @user.stub!(:roles).and_return [@user_role]
          @content.user_has_role?(@user, :admin).should be_false
        end  
      end

      describe 'with @user, :moderator passed' do
        it "yields true if the user has an admin role for the content's site" do
          @user.stub!(:roles).and_return [@admin_role]
          @content.user_has_role?(@user, :moderator).should be_true
        end  
      
        it "yields true if the user has a moderator role for the content's section" do
          @user.stub!(:roles).and_return [@moderator_role]
          @content.user_has_role?(@user, :moderator).should be_true
        end  
      
        it 'yields false if the user does not have an appropriate role' do
          @user.stub!(:roles).and_return [@user_role]
          @content.user_has_role?(@user, :moderator).should be_false
        end  
      end

      describe 'with @user, :author passed' do
        it "yields true if the user has an admin role for the content's site" do
          @user.stub!(:roles).and_return [@admin_role]
          @content.user_has_role?(@user, :author).should be_true
        end
      
        it "yields true if the user has a moderator role for the content's section" do
          @user.stub!(:roles).and_return [@moderator_role]
          @content.user_has_role?(@user, :author).should be_true
        end  
      
        it "yields true if the user is the content's author" do
          @user.stub!(:roles).and_return []
          @user.stub!(:id).and_return 1
          @content.user_has_role?(@user, :author).should be_true
        end  
      
        it 'yields false if the user does not have an appropriate role' do
          @user.stub!(:roles).and_return [@user_role]
          @content.user_has_role?(@user, :author).should be_false
        end  
      end
    end
  end
  
  describe Wiki do
    describe "#default_required_roles" do
      it 'returns a hash of default role mappings' do
        Wiki.default_required_roles[:manage_wikipages].should == :user
      end
    end
  end
end