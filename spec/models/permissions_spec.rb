require File.dirname(__FILE__) + '/../spec_helper'

describe 'Models #default_permissions' do
  before :each do 
    @default_permissions = {
      :site    => { :theme    => { :show => :admin, :update => :admin, :create => :admin, :destroy => :admin }, 
                    :user     => { :show => :admin, :update => :admin, :create => :admin, :destroy => :admin }, 
                    :section  => { :show => :admin, :update => :admin, :create => :admin, :destroy => :admin }, 
                    :site     => { :show => :admin, :update => :admin, :create => :superuser, :destroy => :superuser, :manage => :admin } },

      :section => { :article  => { :update => :moderator, :create => :moderator, :destroy => :moderator, :show => :moderator }, 
                    :category => { :update => :moderator, :create => :moderator, :destroy => :moderator, :show => :moderator } },

      :blog    => { :category => { :update => :moderator, :create => :moderator, :destroy => :moderator, :show => :moderator },
                    :article  => { :show => :anonymous, :update => :user, :create => :user, :destroy => :user }, 
                    :comment  => { :update => :author, :destroy => :author, :create => :user } },

      :forum   => { :comment  => { :update => :author, :destroy => :author, :create => :user }, 
                    :topic    => { :moderate => :moderator, :update => :user, :destroy => :moderator, :create => :user } },

      :wiki    => { :category => { :update => :moderator, :create => :moderator, :destroy => :moderator, :show => :moderator },
                    :comment  => { :update => :author, :destroy => :author, :create => :user }, 
                    :wikipage => { :show => :anonymous, :update => :user, :create => :user, :destroy => :user}}
    }
  end

  it 'should return proper permissions for Site' do
    Site.default_permissions.to_hash.should == @default_permissions[:site]
  end

  it 'should return proper permissions for Section' do
    Section.default_permissions.to_hash.should == @default_permissions[:section]
  end

  it 'should return proper permissions for Blog' do
    Blog.default_permissions.to_hash.should == @default_permissions[:blog]
  end

  it 'should return proper permissions for Forum' do
    Forum.default_permissions.to_hash.should == @default_permissions[:forum]
  end

  it 'should return proper permissions for Wiki' do
    Wiki.default_permissions.to_hash.should == @default_permissions[:wiki]
  end
end