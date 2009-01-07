require File.dirname(__FILE__) + '/../spec_helper'

module SpecWithGlobalHelper
  def with_global(name, value)
    backup = name.gsub(/\W/, '_').downcase
    before(:each) { eval "@#{backup}, #{name} = #{name}, #{value.inspect}" }
    after(:each)  { eval "#{name} = @#{backup}" }
  end
end

module ThemeAssetTagSpecHelper
  def urls_from(tags)
    tags.map do |tag|
      tag =~ /(href|src)="([^"\?]*)(\?|")/
      $2
    end
  end
end

describe ActionView::Helpers::AssetTagHelper, '#theme_image_tag' do
  extend SpecWithGlobalHelper
  include ThemeAssetTagSpecHelper

  before :each do
    File.stub!(:read).and_return 'contents'
    File.stub!(:mtime).and_return Time.now

    ActionView::Helpers::AssetTagHelper::AssetTag::Cache.clear

    @controller = mock 'controller', :site => mock('Site', :id => 1, :perma_host => 'adva-cms.org', :attributes => {'id' => 1})
    helper.instance_variable_set(:@controller, @controller) # yuck
  end

  after :each do
    %w(themes/site-1/ public/themes/ public/cache/).each do |dir|
      FileUtils.rm_r "#{RAILS_ROOT}/#{dir}" if File.exists?("#{RAILS_ROOT}/#{dir}")
    end
  end

  describe "in single-site mode" do
    with_global("Site.multi_sites_enabled", false)

    before :each do
      @helper = lambda { helper.theme_image_tag('theme-1', 'logo.png') }

      @source = "#{RAILS_ROOT}/themes/site-1/theme-1/images/logo.png"
      @destination = lambda { |name| "public/themes/theme-1/images/#{name}.png" }

      FileUtils.mkdir_p File.dirname(@source)
      FileUtils.touch @source
    end

    it "generate a tag linking to '/themes/:theme_id/images/:source.png'" do
      urls = urls_from @helper.call
      urls.should == %w(/themes/theme-1/images/logo.png)
    end

    it "copies the image file from /themes/:site_id/:theme_id/images/:source.png \
        to /public/themes/:theme_id/images/:source.png" do
      FileUtils.should_receive(:cp).with @source, RAILS_ROOT + '/' + @destination.call('logo')
      @helper.call
    end
  end

  describe "in multi-site mode" do
    with_global("Site.multi_sites_enabled", true)

    before :each do
      @helper = lambda { helper.theme_image_tag('theme-1', 'logo.png') }

      @source = "#{RAILS_ROOT}/themes/site-1/theme-1/images/logo.png"
      @destination = lambda { |name| "public/cache/adva-cms.org/themes/theme-1/images/#{name}.png" }

      FileUtils.mkdir_p File.dirname(@source)
      FileUtils.touch @source
    end

    it "generate a tag linking to '/themes/:theme_id/images/:source.png'" do
      urls = urls_from @helper.call
      urls.should == %w(/themes/theme-1/images/logo.png)
    end

    it "copies the image file from /themes/:site_id/:theme_id/images/:source.png \
        to /public/cache/adva-cms.org/themes/:theme_id/images/:source.png" do
      FileUtils.should_receive(:cp).with @source, RAILS_ROOT + '/' + @destination.call('logo')
      @helper.call
    end
  end
end

describe ActionView::Helpers::AssetTagHelper, '#theme_javascript_include_tag' do
  extend SpecWithGlobalHelper
  include ThemeAssetTagSpecHelper

  before :each do
    File.stub!(:read).and_return 'contents'
    File.stub!(:mtime).and_return Time.now

    ActionView::Helpers::AssetTagHelper::AssetTag::Cache.clear
    ActionView::Helpers::AssetTagHelper::AssetCollection::Cache.clear # yuck

    @controller = mock 'controller', :site => mock('Site', :id => 1, :perma_host => 'adva-cms.org', :attributes => {'id' => 1})
    helper.instance_variable_set(:@controller, @controller) # yuck
  end

  after :each do
    %w(themes/site-1/ public/themes/ public/cache/).each do |dir|
      FileUtils.rm_r "#{RAILS_ROOT}/#{dir}" if File.exists?("#{RAILS_ROOT}/#{dir}")
    end
  end

  describe "in single-site mode" do
    with_global("Site.multi_sites_enabled", false)

    before :each do
      @source = "#{RAILS_ROOT}/themes/site-1/theme-1/javascripts/effects.js"
      @destination = lambda { |name| "public/themes/theme-1/javascripts/#{name}.js" }
    end

    describe "with perform_caching disabled" do
      before :each do
        @helper = lambda { helper.theme_javascript_include_tag('theme-1', 'effects', 'more-effects') }
      end

      with_global("ActionController::Base.perform_caching", false)

      it "generates tags linking to '/themes/:theme_id/javascripts/:source.js'" do
        urls = urls_from @helper.call
        urls.should == %w(/themes/theme-1/javascripts/effects.js /themes/theme-1/javascripts/more-effects.js)
      end

      it "reads the file contents from /themes/:site_id/:theme_id/javascripts/:source.js" do
        File.should_receive(:read).with(@source)
        @helper.call
      end

      it "writes the asset file contents to /public/themes/:theme_id/javascripts/:source.js" do
        @helper.call
        File.exist?(@destination.call('effects')).should be_true
      end
    end

    describe "with perform_caching enabled" do
      with_global("ActionController::Base.perform_caching", true)

      describe "given no cache option" do
        before :each do
          @helper = lambda { helper.theme_javascript_include_tag('theme-1', 'effects', 'more-effects') }
        end

        it "generates tags linking to '/themes/:theme_id/javascripts/:source.js'" do
          urls_from(@helper.call).should == %w(/themes/theme-1/javascripts/effects.js /themes/theme-1/javascripts/more-effects.js)
        end

        it "reads the file contents from /themes/:site_id/:theme_id/javascripts/:source.js" do
          File.should_receive(:read).with(@source)
          @helper.call
        end

        it "writes the asset file contents to /public/themes/:theme_id/javascripts/:source.js" do
          @helper.call
          File.exist?(@destination.call('effects')).should be_true
        end
      end

      describe "given cache => true" do
        before :each do
          @helper = lambda { helper.theme_javascript_include_tag('theme-1', 'effects', :cache => true) }
        end

        it "generates tags linking to '/themes/:theme_id/javascripts/all.js'" do
          urls_from(@helper.call).should == %w(/themes/theme-1/javascripts/all.js)
        end

        it "reads the file contents from /themes/:site_id/:theme_id/:source.js" do
          File.should_receive(:read).with(@source)
          @helper.call
        end

        it "writes the joined asset file contents to /public/themes/:theme_id/javascripts/all.js" do
          @helper.call
          File.exist?(@destination.call('all')).should be_true
        end
      end

      describe "given cache => 'foo'" do
        before :each do
          @helper = lambda { helper.theme_javascript_include_tag('theme-1', 'effects', :cache => 'foo') }
        end

        it "generates tags linking to '/themes/:theme_id/javascripts/all.js'" do
          urls_from(@helper.call).should == %w(/themes/theme-1/javascripts/foo.js)
        end

        it "reads the file contents from /themes/:site_id/:theme_id/:source.js" do
          File.should_receive(:read).with(@source)
          @helper.call
        end

        it "writes the joined asset file contents to /public/themes/:theme_id/javascripts/foo.js" do
          @helper.call
          File.exist?(@destination.call('foo')).should be_true
        end
      end
    end
  end

  describe "in multi-site mode" do
    with_global("Site.multi_sites_enabled", true)

    before :each do
      @source = "#{RAILS_ROOT}/themes/site-1/theme-1/javascripts/effects.js"
      @destination = lambda { |name| "public/cache/adva-cms.org/themes/theme-1/javascripts/#{name}.js" }
    end

    describe "with perform_caching disabled" do
      with_global("ActionController::Base.perform_caching", false)

      it "generates tags linking to '/themes/:theme_id/javascripts/:source.js'" do
        urls = urls_from helper.theme_javascript_include_tag('theme-1', 'effects', 'more-effects')
        urls.should == %w(/themes/theme-1/javascripts/effects.js /themes/theme-1/javascripts/more-effects.js)
      end

      it "reads the file contents from /themes/:site_id/:theme_id/javascripts/:source.js" do
        File.should_receive(:read).with(@source)
        helper.theme_javascript_include_tag('theme-1', 'effects')
      end

      it "writes the asset file contents to /public/cache/adva-cms.org/themes/:theme_id/javascripts/:source.js" do
        helper.theme_javascript_include_tag('theme-1', 'effects')
        File.exist?(@destination.call('effects')).should be_true
      end
    end

    describe "with perform_caching enabled" do
      with_global("ActionController::Base.perform_caching", true)

      describe "given no cache option" do
        before :each do
          @helper = lambda { helper.theme_javascript_include_tag('theme-1', 'effects', 'more-effects') }
        end

        it "generates tags linking to '/themes/:theme_id/javascripts/:source.js'" do
          urls_from(@helper.call).should == %w(/themes/theme-1/javascripts/effects.js /themes/theme-1/javascripts/more-effects.js)
        end

        it "reads the file contents from /themes/:site_id/:theme_id/javascripts/:source.js" do
          File.should_receive(:read).with(@source)
          @helper.call
        end

        it "writes the asset file contents to /public/cache/adva-cms.org/themes/:theme_id/javascripts/:source.js" do
          @helper.call
          File.exist?(@destination.call('effects')).should be_true
        end
      end

      describe "given cache => true" do
        before :each do
          @helper = lambda { helper.theme_javascript_include_tag('theme-1', 'effects', :cache => true) }
        end

        it "generates tags linking to '/themes/:theme_id/javascripts/all.js'" do
          urls_from(@helper.call).should == %w(/themes/theme-1/javascripts/all.js)
        end

        it "reads the file contents from /themes/:site_id/:theme_id/:source.js" do
          File.should_receive(:read).with(@source)
          @helper.call
        end

        it "writes the joined asset file contents to /public/cache/adva-cms.org/themes/:theme_id/javascripts/all.js" do
          @helper.call
          File.exist?(@destination.call('all')).should be_true
        end
      end

      describe "given cache => 'foo'" do
        before :each do
          @helper = lambda { helper.theme_javascript_include_tag('theme-1', 'effects', :cache => 'foo') }
        end

        it "generates tags linking to '/themes/:theme_id/javascripts/all.js'" do
          urls_from(@helper.call).should == %w(/themes/theme-1/javascripts/foo.js)
        end

        it "reads the file contents from /themes/:site_id/:theme_id/:source.js" do
          File.should_receive(:read).with(@source)
          @helper.call
        end

        it "writes the joined asset file contents to /public/cache/adva-cms.org/themes/:theme_id/javascripts/foo.js" do
          @helper.call
          File.exist?(@destination.call('foo')).should be_true
        end
      end
    end
  end
end

describe ActionView::Helpers::AssetTagHelper, '#theme_stylesheet_link_tag' do
  extend SpecWithGlobalHelper
  include ThemeAssetTagSpecHelper

  before :each do
    File.stub!(:read).and_return 'contents'
    File.stub!(:mtime).and_return Time.now

    ActionView::Helpers::AssetTagHelper::AssetTag::Cache.clear
    ActionView::Helpers::AssetTagHelper::AssetCollection::Cache.clear # yuck

    @controller = mock 'controller', :site => mock('Site', :id => 1, :perma_host => 'adva-cms.org', :attributes => {'id' => 1})
    helper.instance_variable_set(:@controller, @controller) # yuck
  end

  after :each do
    %w(themes/site-1/ public/themes/ public/cache/).each do |dir|
      FileUtils.rm_r "#{RAILS_ROOT}/#{dir}" if File.exists?("#{RAILS_ROOT}/#{dir}")
    end
  end

  describe "in single-site mode" do
    with_global("Site.multi_sites_enabled", false)

    before :each do
      @source = "#{RAILS_ROOT}/themes/site-1/theme-1/stylesheets/styles.css"
      @destination = lambda { |name| "public/themes/theme-1/stylesheets/#{name}.css" }
    end

    describe "with perform_caching disabled" do
      before :each do
        @helper = lambda { helper.theme_stylesheet_link_tag('theme-1', 'styles', 'more-styles') }
      end

      with_global("ActionController::Base.perform_caching", false)

      it "generates tags linking to '/themes/:theme_id/stylesheets/:source.css'" do
        urls = urls_from @helper.call
        urls.should == %w(/themes/theme-1/stylesheets/styles.css /themes/theme-1/stylesheets/more-styles.css)
      end

      it "reads the file contents from /themes/:site_id/:theme_id/stylesheets/:source.css" do
        File.should_receive(:read).with(@source)
        @helper.call
      end

      it "writes the asset file contents to /public/themes/:theme_id/stylesheets/:source.css" do
        @helper.call
        File.exist?(@destination.call('styles')).should be_true
      end
    end

    describe "with perform_caching enabled" do
      with_global("ActionController::Base.perform_caching", true)

      describe "given no cache option" do
        before :each do
          @helper = lambda { helper.theme_stylesheet_link_tag('theme-1', 'styles', 'more-styles') }
        end

        it "generates tags linking to '/themes/:theme_id/stylesheets/:source.css'" do
          urls_from(@helper.call).should == %w(/themes/theme-1/stylesheets/styles.css /themes/theme-1/stylesheets/more-styles.css)
        end

        it "reads the file contents from /themes/:site_id/:theme_id/stylesheets/:source.css" do
          File.should_receive(:read).with(@source)
          @helper.call
        end

        it "writes the asset file contents to /public/themes/:theme_id/stylesheets/:source.css" do
          @helper.call
          File.exist?(@destination.call('styles')).should be_true
        end
      end

      describe "given cache => true" do
        before :each do
          @helper = lambda { helper.theme_stylesheet_link_tag('theme-1', 'styles', :cache => true) }
        end

        it "generates tags linking to '/themes/:theme_id/stylesheets/all.css'" do
          urls_from(@helper.call).should == %w(/themes/theme-1/stylesheets/all.css)
        end

        it "reads the file contents from /themes/:site_id/:theme_id/:source.css" do
          File.should_receive(:read).with(@source)
          @helper.call
        end

        it "writes the joined asset file contents to /public/themes/:theme_id/stylesheets/all.css" do
          @helper.call
          File.exist?(@destination.call('all')).should be_true
        end
      end

      describe "given cache => 'foo'" do
        before :each do
          @helper = lambda { helper.theme_stylesheet_link_tag('theme-1', 'styles', :cache => 'foo') }
        end

        it "generates tags linking to '/themes/:theme_id/stylesheets/all.css'" do
          urls_from(@helper.call).should == %w(/themes/theme-1/stylesheets/foo.css)
        end

        it "reads the file contents from /themes/:site_id/:theme_id/:source.css" do
          File.should_receive(:read).with(@source)
          @helper.call
        end

        it "writes the joined asset file contents to /public/themes/:theme_id/stylesheets/foo.css" do
          @helper.call
          File.exist?(@destination.call('foo')).should be_true
        end
      end
    end
  end

  describe "in multi-site mode" do
    with_global("Site.multi_sites_enabled", true)

    before :each do
      @source = "#{RAILS_ROOT}/themes/site-1/theme-1/stylesheets/styles.css"
      @destination = lambda { |name| "public/cache/adva-cms.org/themes/theme-1/stylesheets/#{name}.css" }
    end

    describe "with perform_caching disabled" do
      with_global("ActionController::Base.perform_caching", false)
    
      it "generates tags linking to '/themes/:theme_id/stylesheets/:source.css'" do
        urls = urls_from helper.theme_stylesheet_link_tag('theme-1', 'styles', 'more-styles')
        urls.should == %w(/themes/theme-1/stylesheets/styles.css /themes/theme-1/stylesheets/more-styles.css)
      end
    
      it "reads the file contents from /themes/:site_id/:theme_id/stylesheets/:source.css" do
        File.should_receive(:read).with(@source)
        helper.theme_stylesheet_link_tag('theme-1', 'styles')
      end
    
      it "writes the asset file contents to /public/cache/adva-cms.org/themes/:theme_id/stylesheets/:source.css" do
        helper.theme_stylesheet_link_tag('theme-1', 'styles')
        File.exist?(@destination.call('styles')).should be_true
      end
    end

    describe "with perform_caching enabled" do
      with_global("ActionController::Base.perform_caching", true)

      describe "given no cache option" do
        before :each do
          @helper = lambda { helper.theme_stylesheet_link_tag('theme-1', 'styles', 'more-styles') }
        end
      
        it "generates tags linking to '/themes/:theme_id/stylesheets/:source.css'" do
          urls_from(@helper.call).should == %w(/themes/theme-1/stylesheets/styles.css /themes/theme-1/stylesheets/more-styles.css)
        end
      
        it "reads the file contents from /themes/:site_id/:theme_id/stylesheets/:source.css" do
          File.should_receive(:read).with(@source)
          @helper.call
        end
      
        it "writes the asset file contents to /public/cache/adva-cms.org/themes/:theme_id/stylesheets/:source.css" do
          @helper.call
          File.exist?(@destination.call('styles')).should be_true
        end
      end
      
      describe "given cache => true" do
        before :each do
          @helper = lambda { helper.theme_stylesheet_link_tag('theme-1', 'styles', :cache => true) }
        end
      
        it "generates tags linking to '/themes/:theme_id/stylesheets/all.css'" do
          urls_from(@helper.call).should == %w(/themes/theme-1/stylesheets/all.css)
        end
      
        it "reads the file contents from /themes/:site_id/:theme_id/:source.css" do
          File.should_receive(:read).with(@source)
          @helper.call
        end
      
        it "writes the joined asset file contents to /public/cache/adva-cms.org/themes/:theme_id/stylesheets/all.css" do
          @helper.call
          File.exist?(@destination.call('all')).should be_true
        end
      end

      describe "given cache => 'foo'" do
        before :each do
          @helper = lambda { helper.theme_stylesheet_link_tag('theme-1', 'styles', :cache => 'foo') }
        end

        it "generates tags linking to '/themes/:theme_id/stylesheets/all.css'" do
          urls_from(@helper.call).should == %w(/themes/theme-1/stylesheets/foo.css)
        end

        it "reads the file contents from /themes/:site_id/:theme_id/:source.css" do
          File.should_receive(:read).with(@source)
          @helper.call
        end

        it "writes the joined asset file contents to /public/cache/adva-cms.org/themes/:theme_id/stylesheets/foo.css" do
          @helper.call
          File.exist?(@destination.call('foo')).should be_true
        end
      end
    end
  end
end