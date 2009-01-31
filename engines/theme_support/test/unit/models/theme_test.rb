require File.dirname(__FILE__) + '/../../test_helper'

class ThemeTest < ActiveSupport::TestCase
  @@about = { 'author' => 'Sven Fuchs',
              'homepage' => 'http://www.artweb-design.de',
              'version' => '0.1',
              'summary' => 'awesome' }

  def setup
    super
    Theme.root_dir = RAILS_ROOT + '/tmp'
    
    theme_dir = "#{Theme.base_dir}/theme_1"
    FileUtils.mkdir_p(theme_dir) unless File.exists?(theme_dir)
    ::File.open("#{theme_dir}/about.yml", 'wb+') { |f| f.write(@@about.to_yaml) }

    @theme_attributes = @@about.clone.merge('path' => "#{Theme.base_dir}/")
    @theme = call_find(:find, 'theme_1')
  end
  
  # find
  test "finder called with theme_id and without subdir finds and returns an installed theme" do
    it_finds_one_theme 'theme_1'
  end

  test "finder called without theme_id and subdir finds and returns all installed themes" do
    it_finds_all_themes
  end
  
  test "finder called with theme_id and with subdir finds and returns an installed theme" do
    it_finds_one_theme 'theme_1', 'subdir/'
  end

  test "finder called without theme_id and with subdir finds and returns all installed themes" do
    it_finds_all_themes 'subdir/'
  end
  
  # create!
  test "create! creates the theme directory and saves the about.yml file" do
    Theme.create! @theme_attributes.merge('name' => 'theme_2')
    "#{Theme.root_dir}/themes/theme_2/about.yml".should be_file
  end

  # about
  test "loads about data" do
    @theme.send(:about).should == @@about
  end

  ['author', 'homepage', 'version', 'summary'].each do |property|
    test "return about attribute #{property}" do
      @theme.send(property).should == @@about[property]
    end
  end
  
  test "should return 'unknown' as an author_link when no homepage and no author is set" do
    @theme.send(:about).delete 'homepage'
    @theme.send(:about).delete 'author'
    @theme.author_link.should == 'unknown'
  end
  
  test "should return author as an author_link when no homepage is set" do
    @theme.send(:about).delete 'homepage'
    @theme.author_link.should == @@about['author']
  end
  
  test "should return an html link as an author_link when homepage is set" do
    @theme.author_link.should == %(<a href="#{@@about['homepage']}">#{@@about['author']}</a>)
  end

  # name=
  test "name= updates the theme id when assigned a different name" do
    mock(@theme).id=('new_theme_name')
    @theme.name = 'new theme name'
  end
  
  # id=
  test "id= moves the theme directory when the id changes" do
    mock(@theme).mv(Pathname.new("#{Theme.base_dir}/new_theme_name"))
    @theme.id = 'new_theme_name'
  end

  # mv
  test "mv renames the theme directory" do
    target = "#{Theme.base_dir}/new_theme_name"
    mock(FileUtils).mv("#{Theme.base_dir}/#{@theme.id}", target)
    @theme.mv target
  end

  test "fails when the theme directory could not be renamed" do
    @other_theme = Theme.create! @@about.clone.merge('path' => "#{Theme.base_dir}/", 'name' => 'other_theme_name')
    lambda{ @theme.mv "#{Theme.base_dir}/other_theme_name" }.should raise_error(Theme::ThemeError)
  end

  protected

    def it_finds_one_theme(id, subdir = nil)
      theme = call_find(:find, id, subdir)
      theme.should be_instance_of(Theme)
      theme.id.should == 'theme_1'
    end
  
    def it_finds_all_themes(subdir = nil)
      themes = call_find(:find, :all, subdir)
      themes.should be_instance_of(Array)
      themes.first.should be_instance_of(Theme)
      themes.map(&:id).should == ['theme_1', 'theme_2']
    end

    def call_find(finder, *args)
      subdir = args.size > 1 ? args.last : nil
      stub(File).directory?.returns(true)
      stub(Dir).glob(anything).returns [1, 2].collect{|ix| "#{Theme.base_dir}/#{subdir}theme_#{ix}" }
      Theme.send finder, *args
    end
end
