require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class NewsletterTest < ActiveSupport::TestCase
  def setup
    super
    @site = Site.find_by_name("site with newsletter")
    @newsletter = Adva::Newsletter.first
  end

  test "associations" do
    @newsletter.should have_many(:issues)
    @newsletter.should have_many(:subscriptions, :as => :subscribable)
    @newsletter.should have_many(:users, :through => :subscriptions)
  end

  test "validations" do
    @newsletter.should validate_presence_of(:title)
    @newsletter.should validate_presence_of(:site_id)
  end

  test "published scope" do
    Adva::Newsletter.published.proxy_options[:conditions].should == "adva_newsletters.published = 1"
  end

  test "#available_users should return all site users except already subscribed" do
    newsletter = Adva::Newsletter.find_by_title("newsletter without subscriptions")
    newsletter.available_users.size.should == 2
    new_subscriber = newsletter.subscriptions.create :user_id => @site.users.first.id
    newsletter.available_users.size.should == 1
  end

  test "#email should provide site.email when newsletter.email is nil" do
    @newsletter.email = nil
    @newsletter.site.email = "admin@example.org"
    @newsletter.email.should == "admin@example.org"
  end

  test "#do_not_save_default_email should not store email when it is same as site.email" do
    @newsletter.site.email = "admin@example.org"
    @newsletter.email = "admin@example.org"
    @newsletter.save
    @newsletter.read_attribute(:email).should be_nil
  end

  test "#name should return newsletter name" do
    @newsletter.name = "Newsletter name"
    @newsletter.name.should == "Newsletter name"
  end

  test "#name should return site name when newsletter.name is nil" do
    @newsletter.name = nil
    @newsletter.name.should == @site.name
  end

  test "#email_with_name should return formatted email with name" do
    @newsletter.name.should == "site with newsletter"
    @newsletter.email.should == "newsletter@example.com"
    @newsletter.email_with_name.should == "site with newsletter <newsletter@example.com>"
  end

  test "#published? should be true if published" do
    @newsletter.published = 1
    @newsletter.should be_published
  end

  test "#published? should be false if not published" do
    @newsletter.published = 0
    @newsletter.should_not be_published
  end

  test "#state should be pending when draft" do
    @newsletter.published = 0
    @newsletter.state.should == "pending"
  end

  test "#state should be published when published" do
    @newsletter.published = 1
    @newsletter.state.should == "published"
  end
end
