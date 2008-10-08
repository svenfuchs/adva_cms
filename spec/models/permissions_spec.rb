require File.dirname(__FILE__) + '/../spec_helper'

describe 'Models #default_permissions' do
  before :each do
    @default_permissions = {
      :site    => { :theme    => { :show => :admin, :update => :admin, :create => :admin, :destroy => :admin },
                    :user     => { :show => :admin, :update => :admin, :create => :admin, :destroy => :admin },
                    :section  => { :show => :admin, :update => :admin, :create => :admin, :destroy => :admin },
                    :site     => { :show => :admin, :update => :admin, :create => :superuser, :destroy => :superuser, :manage => :admin },
                    :comment  => { :show => :admin, :update => :admin, :create => :admin, :destroy => :admin } },

      :section => { :article  => { :show => :moderator, :update => :moderator, :create => :moderator, :destroy => :moderator },
                    :category => { :show => :moderator, :update => :moderator, :create => :moderator, :destroy => :moderator } },

      :blog    => { :category => { :show => :moderator, :create => :moderator, :update => :moderator, :destroy => :moderator },
                    :article  => { :show => :moderator, :create => :moderator, :update => :moderator, :destroy => :moderator },
                    :comment  => { :show => :anonymous, :create => :user, :update => :author, :destroy => :moderator } },

      :forum   => { :comment  => { :show => :anonymous, :create => :user, :update => :author, :destroy => :author },
                    :topic    => { :show => :anonymous, :create => :user, :update => :author, :destroy => :moderator, :moderate => :moderator } },

      :wiki    => { :category => { :show => :anonymous, :create => :moderator, :update => :moderator, :destroy => :moderator },
                    :comment  => { :show => :anonymous, :create => :user, :update => :author, :destroy => :moderator },
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