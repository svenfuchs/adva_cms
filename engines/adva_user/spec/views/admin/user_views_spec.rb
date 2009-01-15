require File.dirname(__FILE__) + '/../../spec_helper'

describe "Admin::User:" do
  include SpecViewHelper

  before :each do
    @user = stub_user
    @users = stub_users
    assigns[:site] = @site = stub_site

    set_resource_paths :user, '/admin/'

    template.stub!(:collection_path).and_return(@collection_path)
    template.stub!(:member_path).and_return(@member_path)
    template.stub!(:new_member_path).and_return(@new_member_path)
    template.stub!(:edit_member_path).and_return(@edit_member_path)

    template.stub!(:gravatar_img)
    template.stub!(:current_user).and_return @user
    template.stub!(:will_paginate).and_return "will_paginate"
    template.stub!(:link_to_cancel).and_return "link to cancel"
  end

  describe "the :index view" do
    before :each do
      assigns[:users] = @users
    end

    it "displays a list of users" do
      render "admin/users/index"
      response.should have_tag('ul[id=?]', 'users')
    end
  end

  describe "the :show view" do
    before :each do
      assigns[:user] = @user
      template.stub!(:render).with hash_including(:partial => 'form')
    end

    it "displays a the user profile" do
      render "admin/users/show"
      response.should have_tag('h2', @user.name)
    end
  end

  describe "the :new view" do
    before :each do
      assigns[:user] = @user
      template.stub!(:render).with hash_including(:partial => 'form')
    end

    it "displays a form to add a new user" do
      render "admin/users/new"
      response.should have_tag('form[action=?][method=?]', @collection_path, :post)
    end

    it "renders the form partial" do
      template.should_receive(:render).with hash_including(:partial => 'form')
      render "admin/users/new"
    end
    
    it "uses link_to_cancel helper method to create a cancel link" do
      template.should_receive(:link_to_cancel).and_return('link to cancel')
      render "admin/users/new"
    end

    describe "with the current user having permissions to manage roles" do
      it "renders the roles partial" # do
      #   template.should_receive(:has_permission?).with('manage', 'roles').and_return true
      #   template.expect_render hash_including(:partial => 'roles')
      #   render "admin/users/edit"
      # end
    end

    describe "with the current user not having permissions to manage roles" do
      it "does not render the roles partial" do
        template.should_receive(:has_permission?).with('manage', 'roles').and_return false
        template.should_not_receive(:render).with hash_including(:partial => 'roles')
        render "admin/users/edit"
      end
    end
  end

  describe "the :edit view" do
    before :each do
      assigns[:user] = @user
      template.stub!(:render).with hash_including(:partial => 'form')
      template.stub!(:has_permission?).and_return false
    end

    it "displays a form to edit the user" do
      render "admin/users/edit"
      response.should have_tag('form[action=?]', @member_path) do |form|
        form.should have_tag('input[name=?][value=?]', '_method', 'put')
        form.should have_tag('input[name=?][value=?]', '_method', 'put')
      end
    end

    it "renders the form partial" do
      template.should_receive(:render).with hash_including(:partial => 'form')
      render "admin/users/edit"
    end
    
    it "uses link_to_cancel helper method to create a cancel link" do
      template.should_receive(:link_to_cancel).and_return('link to cancel')
      render "admin/users/edit"
    end

    describe "with the current user having permissions to manage roles" do
      it "renders the roles partial" # do
      #   template.should_receive(:has_permission?).with('manage', 'roles').and_return true
      #   template.expect_render hash_including(:partial => 'roles')
      #   render "admin/users/edit"
      # end
    end

    describe "with the current user not having permissions to manage roles" do
      it "does not render the roles partial" do
        # template.should_receive(:has_permission?).with('manage', 'roles').and_return false
        template.should_not_receive(:render).with hash_including(:partial => 'roles')
        render "admin/users/edit"
      end
    end
  end

  describe "the form partial" do
    before :each do
      assigns[:user] = @user
      template.stub!(:f).and_return ActionView::Base.default_form_builder.new(:user, @user, template, {}, nil)
    end

    it "renders user settings fields" do
      render "admin/users/_form"
      response.should have_tag('input[name=?]', 'user[email]')
      response.should have_tag('input[name=?]', 'user[email]')
    end
  end

  describe "the roles partial" do
    before :each do
      assigns[:user] = @user
      template.stub!(:f).and_return ActionView::Base.default_form_builder.new(:user, @user, template, {}, nil)
    end

    # response.should have_tag('input[type=?][name=?]', 'checkbox', 'user[roles][0][selected]')

    describe "when rendered outside of site scope" do
      before :each do assigns[:site] = nil end

      it "does not render a checkbox for adding the admin role" do
        render "admin/users/_roles"
        response.should_not have_tag('input[type=?][name=?][value=?]', 'hidden', 'user[roles][1][type]', 'Rbac::Role::Admin')
        response.should_not have_tag('input[type=?][name=?][value=?]', 'hidden', 'user[roles][1][type]', 'Rbac::Role::Admin')
      end
    end

    describe "when rendered inside of site scope" do
      it "renders a checkbox for adding the admin role" # do
      #   render "admin/users/_roles"
      #   response.should have_tag('input[type=?][name=?][value=?]', 'hidden', 'user[roles][1][type]', 'Rbac::Role::Admin')
      #   response.should have_tag('input[type=?][name=?][value=?]', 'hidden', 'user[roles][1][type]', 'Rbac::Role::Admin')
      # end
    end

    describe "with the current user being a superuser" do
      before :each do 
        @user.stub!(:has_role?).and_return true 
      end

      it "renders a checkbox for adding the superuser role" # do
      #   render "admin/users/_roles"
      #   response.should have_tag('input[type=?][name=?][value=?]', 'hidden', 'user[roles][0][type]', 'Rbac::Role::Superuser')
      #   response.should have_tag('input[type=?][name=?][value=?]', 'hidden', 'user[roles][0][type]', 'Rbac::Role::Superuser')
      # end
    end

    describe "with the current user not being a superuser" do
      before :each do
        @user.stub!(:has_role?).and_return false
      end

      it "does not render a checkbox for adding the superuser role" do
        render "admin/users/_roles"
        response.should_not have_tag('input[type=?][first_name=?][value=?]', 'hidden', 'user[roles][0][type]', 'Rbac::Role::Superuser')
        response.should_not have_tag('input[type=?][last_name=?][value=?]', 'hidden', 'user[roles][0][type]', 'Rbac::Role::Superuser')
      end
    end
  end
end
