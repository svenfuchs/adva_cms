require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class AdminBaseHelperTest < ActionView::TestCase
  include Admin::BaseHelper
  include Admin::UsersHelper

  attr_accessor :request

  def setup
    super
    @site = Site.first
    @section = @site.sections.first
    @article = @section.articles.first
    stub(self).current_user.returns User.first

    @admin_site_user_path = %r(/admin/sites/[\d]+/users/[\d]+)
    @admin_user_path      = %r(/admin/users/[\d]+)

    @controller = TestController.new
    @request = ActionController::TestRequest.new
  end

  # save_or_cancel_links
  class TestFormBuilder < ExtensibleFormBuilder
    def self.reset!
      self.labels = true
      self.wrap = true
      self.default_class_names.clear
    end
  end

  def build_form(&block)
    @controller = Class.new { def url_for(options); 'url' end }.new
    larticle = Article.new(:title => 'article title')
    form_for(:article, @article, :builder => TestFormBuilder, &block)
    output_buffer
  end

  include ::BaseHelper

  test "#save_or_cancel_links uses only button if no cancel url is given" do
    stub(self).protect_against_forgery? { false } # let's make it easier
    html = build_form { |f| save_or_cancel_links(f) }
    html.should have_tag('p.buttons') do |buttons|
      buttons.should have_tag('input[type=?][id=?][value=]', 'submit', 'commit', 'Save')
      html.should_not =~ /or/
      buttons.should_not have_tag('a', 'Cancel')
    end
  end

  test "#save_or_cancel_links uses all parts if cancel url is given" do
    stub(self).protect_against_forgery? { false } # let's make it easier
    html = build_form { |f| save_or_cancel_links(f, :cancel_url => 'cancel url') }
    html.should have_tag('p.buttons') do |buttons|
      buttons.should have_tag('input[type=?][id=?][value=?]', 'submit', 'commit', 'Save')
      html.should =~ /or/
      buttons.should have_tag('a[href=?]', 'cancel url', 'Cancel')
    end
  end

  test "#save_or_cancel_links uses custom save text" do
    stub(self).protect_against_forgery? { false } # let's make it easier
    html = build_form { |f| save_or_cancel_links(f, :save_text => 'save text') }
    html.should have_tag('input[type=?][value=?]', 'submit', 'save text')
  end

  test "#save_or_cancel_links uses custom or text" do
    stub(self).protect_against_forgery? { false } # let's make it easier
    html = build_form { |f| save_or_cancel_links(f, :cancel_url => 'cancel url', :or_text => 'or text') }
    html.should =~ /or text/
  end

  test "#save_or_cancel_links uses custom cancel text" do
    stub(self).protect_against_forgery? { false } # let's make it easier
    html = build_form { |f| save_or_cancel_links(f, :cancel_url => 'cancel url', :cancel_text => 'cancel text') }
    html.should have_tag('a[href=?]', 'cancel url', 'cancel text')
  end

  test "#save_or_cancel_links uses custom save attributes" do
    stub(self).protect_against_forgery? { false } # let's make it easier
    html = build_form { |f| save_or_cancel_links(f, :save => { :class => 'save class' }) }
    html.should have_tag('input[type=?][class=?]', 'submit', 'save class')
  end

  test "#save_or_cancel_links uses custom cancel attributes" do
    stub(self).protect_against_forgery? { false } # let's make it easier
    html = build_form { |f| save_or_cancel_links(f, :cancel_url => 'cancel url', :cancel => { :class => 'cancel class' }) }
    html.should have_tag('a[href=?][class=?]', 'cancel url', 'cancel class')
  end

  # link_to_profile
  test "#link_to_profile links to admin/sites/1/users/1 if site is given" do
    link_to_profile(@site).should =~ @admin_site_user_path
  end

  test "#link_to_profile links to  admin/users/1 if no site is given" do
    link_to_profile.should =~ @admin_user_path
  end

  test "#link_to_profile links to  admin/users/1 if site is a new record" do
    link_to_profile(Site.new).should =~ @admin_user_path
  end

  test "#link_to_profile links to custom link name for profile if specified" do
    link_to_profile(Site.new, :name => 'Dummy').should =~ />Dummy</
  end
end

class CachedPagesHelperTest < ActionView::TestCase
  include Admin::BaseHelper

  def setup
    super
    @page = CachedPage.first

    @time_now = Time.local 2008, 1, 2, 12
    @yesterday = Time.local 2008, 1, 1, 12

    stub(Time).now.returns @time_now # wtf ... time_now_in_words ignores the timezone
    stub(Time.zone).now.returns @time_now
    stub(Time.zone.now).yesterday.returns @yesterday
    stub(Date).today.returns @time_now.to_date
  end

  test '#page_cached_at returns a variant of time_ago_in_words if the cached page was updated no more than 4 hours ago' do
    @page.updated_at = @time_now - 55.minutes
    page_cached_at(@page).should == '~ 1 hour ago'
  end

  test "#page_cached_at returns a formatted date preceeded with 'Today' if the cached page was updated earlier today" do
    @page.updated_at = @time_now - 6.hours
    page_cached_at(@page).should =~ /Today, /
  end

  test "#page_cached_at returns a formatted date if the cached page was updated before today" do
    @page.updated_at = @yesterday
    page_cached_at(@page).should == 'Jan 01, 2008'
  end
end