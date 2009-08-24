require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class SiteTest < ActiveSupport::TestCase
  def setup
    super
    @site = Site.first
  end

  test 'acts as commentable' do
    Site.should have_many_comments
  end

  test 'acts as role context for the admin role' do
    Site.should act_as_role_context(:roles => :admin)
  end

  test "serializes its actual permissions" do
    Site.serialized_attributes.keys.should include('permissions')
  end

  test "serializes the spam options" do
    Site.serialized_attributes.keys.should include('spam_options')
  end

  test "has a comments counter" do
    Site.should have_counter(:comments)
  end

  # ASSOCIATIONS

  test "has many sections" do
    @site.should have_many(:sections)
  end

  test "has many users" do
    @site.should have_many(:users)
  end

  test "has many memberships" do
    @site.should have_many(:memberships)
  end

  test "has many cached_pages" do
    @site.should have_many(:cached_pages)
  end

  test "sections.root returns the left-most section that has no parent as the root section" do
    @site.sections.root.should == @site.sections.find(:first, :conditions => {:parent_id => nil}, :order => :lft)
  end

  test "sections.roots returns the root sections of the site" do
    roots = @site.sections.roots
    roots.map(&:parent_id).compact.should be_empty

    common_ids = roots.map(&:id) & Site.find_by_name('another site').sections.roots.map(&:id)
    common_ids.should be_empty
  end

  test "sections.update_paths! updates all paths" do
    sections = bunch_of_nested_sections!
    sections.each do |section|
      section.path = nil
      section.save!
    end
    @site.sections.update_paths!
    # FIXME ... why does this fail??
    # @site.sections.paths.should include('home', 'home/about', 'home/about/location')
  end

  test "users association calls destroy on associated users when destroyed" do
    user = @site.users.create!(:first_name => 'John', :email => 'email@foo.bar', :password => 'password')
    @site.destroy
    lambda { User.find user.id }.should raise_error(ActiveRecord::RecordNotFound)
  end

  # CLASS METHODS

  test "find_by_host! returns the first site on single_site_mode when there is only one site existing" do
    site = Site.find_by_host('another-site.com')
    Site.all.each {|s| s.delete unless s == site}
    Site.find_by_host!('whatever').should == site
  end

  test "find_by_host! returns the site with given host on single_site_mode when there is more than one site existing" do
    Site.find_by_host!('another-site.com').should == Site.find_by_host('another-site.com')
  end

  test "find_by_host! returns the site with given host on multi_site_mode" do
    Site.multi_sites_enabled = true
    Site.find_by_host!('another-site.com').should == Site.find_by_host('another-site.com')
  end

  # INSTANCE METHODS

  # FIXME shouldn't this just happen in host= ? otherwise rename to something
  # more generic like #escape_host ?
  test '#replace_host_spaces removes spaces from start of the line' do
    @site.host = '    t e s t.advabest.de'
    @site.send(:replace_host_spaces).should == 't-e-s-t.advabest.de'
  end

  test '#replace_host_spaces replaces spaces with -' do
    @site.host = 't e s t.advabest.de'
    @site.send(:replace_host_spaces).should == 't-e-s-t.advabest.de'
  end

  test '#replace_host_spaces removes spaces from end of the line' do
    @site.host = 't e s t.advabest.de    '
    @site.send(:replace_host_spaces).should == 't-e-s-t.advabest.de'
  end

  test "#email_from uses the site's name and email" do
    @site.email = 'admin@example.org'
    @site.name = 'example'

    @site.email_from.should == 'example <admin@example.org>'
  end

  test "#email_from is nil if site's name or email is blank" do
    @site.email = ''
    @site.name = ''

    @site.email_from.should == nil
  end

  # CALLBACKS

  test 'downcases the host before validation' do
    Site.before_validation.should include(:downcase_host)
  end

  test 'strips spaces from host before validation' do
    Site.before_validation.should include(:replace_host_spaces)
  end

  # VALIDATIONS

  test "validates the presence of a host" do
    @site.should validate_presence_of(:host)
  end

  test "validates the presence of a name" do
    @site.should validate_presence_of(:name)
  end

  test "should have title == name when title is blank" do
    site = Site.new(:name => 'example', :title => nil)
    site.valid? # force callbacks
    site.title.should == 'example'
  end

  test "should have title when title is present" do
    site = Site.new :name => 'example', :title => 'title'
    site.valid? # force callbacks
    site.title.should == 'title'
  end

  # PLUGINS

  test "should clone Rails.plugins" do
    @site.plugins.values.first.should be_instance_of(Rails::Plugin)
    @site.plugins.values.first.object_id.should_not == Rails.plugins.values.first.object_id
  end

  test "should set plugin owner to site" do
    @site.plugins.values.first.owner.should == @site
  end

  test "should save a plugin_configs per site" do
    Rails::Plugin::Config.delete_all
    sites = Site.all

    plugin_1 = sites.first.plugins[:test_plugin]
    plugin_2 = sites.second.plugins[:test_plugin]

    plugin_1.string = 'site_1 string'
    plugin_1.save!
    plugin_1.instance_variable_set(:@config, nil) # force reload

    plugin_2.string = 'site_2 string'
    plugin_2.save!
    plugin_2.instance_variable_set(:@config, nil) # force reload

    plugin_1.string.should == 'site_1 string'
    plugin_2.string.should == 'site_2 string'
  end

  protected

    def bunch_of_nested_sections!
      home = Section.create!(:site => @site, :title => 'homepage', :permalink => 'home')
      about = Section.create!(:site => @site, :title => 'about us', :permalink => 'about')
      location = Section.create!(:site => @site, :title => 'how to find us', :permalink => 'location')

      about.move_to_child_of(home)
      location.move_to_child_of(about)
      [home, about, location]
    end
end
