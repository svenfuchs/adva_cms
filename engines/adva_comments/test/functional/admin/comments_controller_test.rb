require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class AdminCommentsControllerTest < ActionController::TestCase
  include ContentHelper, ResourceHelper, BlogHelper
  tests Admin::CommentsController
  attr_reader :controller

  with_common [:a_page, :a_blog], :a_published_article, [:an_approved_comment, :an_unapproved_comment], :is_superuser

  def default_params
    { :site_id => @site.id, :return_to => 'return/to/here' }
  end

  view :comment do
    has_text @comment.body

    comment_path = show_path(@article, :anchor => "comment_#{@comment.id}", :namespace => nil)
    has_tag 'a[href=?]', comment_path, 'View'              # displays a link to the comment on the frontend view
    has_tag 'a', 'Edit'                                    # displays a link to edit the comment
    has_tag 'a', 'Delete'                                  # displays a link to delete the comment
    has_tag 'a', 'Approve'   if within :unapproved_comment # displays a link to approve comment
    has_tag 'a', 'Unapprove' if within :approved_comment   # displays a link to unapprove comment
    # has_tag 'a', 'Reply'   if with? :approved_comment    # displays a link to reply to the comment
  end

  test "is an Admin::BaseController" do
    @controller.should be_kind_of(Admin::BaseController)
  end

  # FIXME in theory the admin comments controller should also work with scoping
  # to a content or a section (currently only tested scoping to a site)

  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/', :site_id => '1' do |r|
      r.it_maps :get,    'comments',        :action => 'index'
      # r.it_maps :get,    'comments/new',    :action => 'new'
      # r.it_maps :post,   'comments',        :action => 'create'
      r.it_maps :get,    'comments/1',      :action => 'show',    :id => '1'
      r.it_maps :get,    'comments/1/edit', :action => 'edit',    :id => '1'
      r.it_maps :put,    'comments/1',      :action => 'update',  :id => '1'
      r.it_maps :delete, 'comments/1',      :action => 'destroy', :id => '1'
    end
  end

  describe "GET to :index" do
    action { get :index, default_params }
    it_guards_permissions :show, :comment

    with :access_granted do
      it_assigns :comments
      it_renders :template, :index do
        # has_tag 'select[id=filter_list]' # displays a filter for filtering the comments list
        has_tag 'ul[id=comments_list]'  # displays a list of comments
        shows :comment
      end
    end
  end

  # describe "GET to :show" do
  #   action { get :show, default_params.merge(:id => @comment.id) }
  #   it_guards_permissions :show, :comment
  # 
  #   with :access_granted do
  #     it_assigns :comment
  #     it_renders :template, :show do
  #       has_tag 'h3', 'Comment'
  #       has_text @comment.body
  #       shows :comment
  #       # FIXME shows a reply form
  #     end
  #   end
  # end

  # FIXME ... implement these
  #
  # describe "GET to :new" do
  #   action { get :new, default_params }
  #   it_guards_permissions :create, :comment
  #   with :access_granted do
  #     it_assigns :comment
  #     it_renders :template, :new
  #   end
  # end
  #
  # describe "POST to :create" do
  #   action { post :create, @params }
  #   it_guards_permissions :create, :comment
  #
  #   with :valid_comment_params do
  #     it_changes '@site.reload.comments.count' => 1
  #     it_redirects_to admin_comment_url(@site, assigns(:comment))
  #     it_assigns_flash_cookie :notice => :not_nil
  #   end
  #
  #   with :invalid_comment_params do
  #     it_does_not_change '@site.reload.comments.count'
  #     it_renders :template, :new
  #     it_assigns_flash_cookie :error => :not_nil
  #   end
  # end

  describe "GET to :edit" do
    action { get :edit, default_params.merge(:id => @comment.id) }
    it_guards_permissions :update, :comment

    with :access_granted do
      it_assigns :comment
      it_renders :template, :edit do
        # FIXME assert form rendered
      end
    end
  end

  describe "PUT to :update" do
    action { put :update, default_params.merge(:id => @comment.id).merge(@params || {}) }
    it_guards_permissions :update, :comment

    with :access_granted do
      it_assigns :comment

      with "valid comment params" do
        before { @params = { :comment => { :body => 'updated comment body' } } }
        it_updates :comment
        it_redirects_to 'return/to/here'
        it_assigns_flash_cookie :notice => :not_nil
        it_triggers_event :comment_updated
      end

      with "invalid comment params" do
        before { @params = { :comment => { :body => '' } } }
        it_does_not_update :comment
        it_assigns_flash_cookie :error => :not_nil
        it_does_not_trigger_any_event
      end
    end
  end

  describe "DELETE to :destroy" do
    action { delete :destroy, default_params.merge(:id => @comment.id) }
    it_guards_permissions :destroy, :comment

    with :access_granted do
      it_assigns :comment
      it_destroys :comment
      it_redirects_to 'return/to/here'
      it_assigns_flash_cookie :notice => :not_nil
      it_triggers_event :comment_deleted
    end
  end

  # def filter_conditions
  #   @controller.send(:filter_options)[:conditions]
  # end
  # 
  # describe "filter_options" do
  #   before { @controller.instance_variable_set :@section, @section }
  # 
  #   it "sets :order, :per_page and :page parameters defaults" do
  #     @controller.params = { :filter => 'all' }
  #     @controller.send(:filter_options).should == { :per_page => nil, :page => 1, :order => 'created_at DESC' }
  #     assert_nothing_raised { @controller.send :set_comments }
  #   end
  # 
  #   it "fetches approved comments when :filter == state and :state == approved" do
  #     @controller.params = { :filter => 'state', :state => 'approved' }
  #     filter_conditions.should == "approved = '1'"
  #     assert_nothing_raised { @controller.send :set_comments }
  #   end
  # 
  #   it "fetches unapproved comments when :filter == state and :state == unapproved" do
  #     @controller.params = { :filter => 'state', :state => 'unapproved' }
  #     filter_conditions.should == "approved = '0'"
  #     assert_nothing_raised { @controller.send :set_comments }
  #   end
  # 
  #   it "fetches comments by matching the body when :filter == body" do
  #     @controller.params = { :filter => 'body', :query => 'foo' }
  #     filter_conditions.should == "LOWER(body) LIKE '%foo%'"
  #     assert_nothing_raised { @controller.send :set_comments }
  #   end
  # 
  #   it "fetches comments by matching the author name when :filter == author_name" do
  #     @controller.params = { :filter => 'author_name', :query => 'foo' }
  #     filter_conditions.should == "LOWER(author_name) LIKE '%foo%'"
  #     assert_nothing_raised { @controller.send :set_comments }
  #   end
  # 
  #   it "fetches comments by matching the author email when :filter == author_email" do
  #     @controller.params = { :filter => 'author_email', :query => 'foo@bar.baz' }
  #     filter_conditions.should == "LOWER(author_email) LIKE '%foo@bar.baz%'"
  #     assert_nothing_raised { @controller.send :set_comments }
  #   end
  # 
  #   it "fetches comments by matching the author homepage when :filter == author_homepage" do
  #     @controller.params = { :filter => 'author_homepage', :query => 'homepage.com' }
  #     filter_conditions.should == "LOWER(author_homepage) LIKE '%homepage.com%'"
  #     assert_nothing_raised { @controller.send :set_comments }
  #   end
  # end
end