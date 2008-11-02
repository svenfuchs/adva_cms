require File.dirname(__FILE__) + '<%= '/..' * class_nesting_depth %>/../spec_helper'

describe <%= controller_class_name %>Controller, "GET #index" do
  # fixture definition

  act! { get :index }

  before do
    @<%= table_name %> = []
    <%= class_name %>.stub!(:find).with(:all).and_return(@<%= table_name %>)
  end
  
  it_assigns :<%= table_name %>
  it_renders :template, :index

<% %w(xml json).each do |format| 
%>  describe <%= controller_class_name %>Controller, "(<%= format %>)" do
    # fixture definition
    
    act! { get :index, :format => '<%= format %>' }

    it_assigns :<%= table_name %>
    it_renders :<%= format %>, :<%= table_name %>
  end

<% end %>
end

describe <%= controller_class_name %>Controller, "GET #show" do
  # fixture definition

  act! { get :show, :id => 1 }

  before do
    @<%= file_name %>  = <%= table_name %>(:default)
    <%= class_name %>.stub!(:find).with('1').and_return(@<%= file_name %>)
  end
  
  it_assigns :<%= file_name %>
  it_renders :template, :show
  
<% %w(xml json).each do |format| 
%>  describe <%= controller_class_name %>Controller, "(<%= format %>)" do
    # fixture definition
    
    act! { get :show, :id => 1, :format => '<%= format %>' }

    it_renders :<%= format %>, :<%= file_name %>
  end

<% end %>
end

describe <%= controller_class_name %>Controller, "GET #new" do
  # fixture definition
  act! { get :new }
  before do
    @<%= file_name %>  = <%= class_name %>.new
  end

  it "assigns @<%= file_name %>" do
    act!
    assigns[:<%= file_name %>].should be_new_record
  end
  
  it_renders :template, :new
  
<% %w(xml json).each do |format| 
%>  describe <%= controller_class_name %>Controller, "(<%= format %>)" do
    # fixture definition
    act! { get :new, :format => '<%= format %>' }

    it_renders :<%= format %>, :<%= file_name %>
  end

<% end %>
end

describe <%= controller_class_name %>Controller, "POST #create" do
  before do
    @attributes = {}
    @<%= file_name %> = mock_model <%= class_name %>, :new_record? => false, :errors => []
    <%= class_name %>.stub!(:new).with(@attributes).and_return(@<%= file_name %>)
  end
  
  describe <%= controller_class_name %>Controller, "(successful creation)" do
    # fixture definition
    act! { post :create, :<%= file_name %> => @attributes }

    before do
      @<%= file_name %>.stub!(:save).and_return(true)
    end
    
    it_assigns :<%= file_name %>, :flash => { :notice => :not_nil }
    it_redirects_to { <%= file_name %>_path(@<%= file_name %>) }
  end

  describe <%= controller_class_name %>Controller, "(unsuccessful creation)" do
    # fixture definition
    act! { post :create, :<%= file_name %> => @attributes }

    before do
      @<%= file_name %>.stub!(:save).and_return(false)
    end
    
    it_assigns :<%= file_name %>
    it_renders :template, :new
  end
  
<% %w(xml json).each do |format| 
%>  describe <%= controller_class_name %>Controller, "(successful creation, <%= format %>)" do
    # fixture definition
    act! { post :create, :<%= file_name %> => @attributes, :format => '<%= format %>' }

    before do
      @<%= file_name %>.stub!(:save).and_return(true)
      @<%= file_name %>.stub!(:to_<%= format %>).and_return("mocked content")
    end
    
    it_assigns :<%= file_name %>, :headers => { :Location => lambda { <%= file_name %>_url(@<%= file_name %>) } }
    it_renders :<%= format %>, :<%= file_name %>, :status => :created
  end
  
  describe <%= controller_class_name %>Controller, "(unsuccessful creation, <%= format %>)" do
    # fixture definition
    act! { post :create, :<%= file_name %> => @attributes, :format => '<%= format %>' }

    before do
      @<%= file_name %>.stub!(:save).and_return(false)
    end
    
    it_assigns :<%= file_name %>
    it_renders :<%= format %>, "<%= file_name %>.errors", :status => :unprocessable_entity
  end

<% end %>end

describe <%= controller_class_name %>Controller, "GET #edit" do
  # fixture definition
  act! { get :edit, :id => 1 }
  
  before do
    @<%= file_name %>  = <%= table_name %>(:default)
    <%= class_name %>.stub!(:find).with('1').and_return(@<%= file_name %>)
  end

  it_assigns :<%= file_name %>
  it_renders :template, :edit
end

describe <%= controller_class_name %>Controller, "PUT #update" do
  before do
    @attributes = {}
    @<%= file_name %> = <%= table_name %>(:default)
    <%= class_name %>.stub!(:find).with('1').and_return(@<%= file_name %>)
  end
  
  describe <%= controller_class_name %>Controller, "(successful save)" do
    # fixture definition
    act! { put :update, :id => 1, :<%= file_name %> => @attributes }

    before do
      @<%= file_name %>.stub!(:save).and_return(true)
    end
    
    it_assigns :<%= file_name %>, :flash => { :notice => :not_nil }
    it_redirects_to { <%= file_name %>_path(@<%= file_name %>) }
  end

  describe <%= controller_class_name %>Controller, "(unsuccessful save)" do
    # fixture definition
    act! { put :update, :id => 1, :<%= file_name %> => @attributes }

    before do
      @<%= file_name %>.stub!(:save).and_return(false)
    end
    
    it_assigns :<%= file_name %>
    it_renders :template, :edit
  end
  
<% %w(xml json).each do |format| 
%>  describe <%= controller_class_name %>Controller, "(successful save, <%= format %>)" do
    # fixture definition
    act! { put :update, :id => 1, :<%= file_name %> => @attributes, :format => '<%= format %>' }

    before do
      @<%= file_name %>.stub!(:save).and_return(true)
    end
    
    it_assigns :<%= file_name %>
    it_renders :blank
  end
  
  describe <%= controller_class_name %>Controller, "(unsuccessful save, <%= format %>)" do
    # fixture definition
    act! { put :update, :id => 1, :<%= file_name %> => @attributes, :format => '<%= format %>' }

    before do
      @<%= file_name %>.stub!(:save).and_return(false)
    end
    
    it_assigns :<%= file_name %>
    it_renders :<%= format %>, "<%= file_name %>.errors", :status => :unprocessable_entity
  end

<% end %>end

describe <%= controller_class_name %>Controller, "DELETE #destroy" do
  # fixture definition
  act! { delete :destroy, :id => 1 }
  
  before do
    @<%= file_name %> = <%= table_name %>(:default)
    @<%= file_name %>.stub!(:destroy)
    <%= class_name %>.stub!(:find).with('1').and_return(@<%= file_name %>)
  end

  it_assigns :<%= file_name %>
  it_redirects_to { <%= table_name %>_path }
  
<% %w(xml json).each do |format| 
%>  describe <%= controller_class_name %>Controller, "(<%= format %>)" do
    # fixture definition
    act! { delete :destroy, :id => 1, :format => '<%= format %>' }

    it_assigns :<%= file_name %>
    it_renders :blank
  end

<% end %>
end