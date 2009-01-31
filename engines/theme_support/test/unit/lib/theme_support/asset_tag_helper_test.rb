require File.dirname(__FILE__) + '/../../../test_helper'

# FIXME change so that it uses directories in tmp/ instead of real directories!

class ThemeAssetTagTest < ActiveSupport::TestCase
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::TagHelper
  
  def setup
    super
    @site = Site.first
    
    @controller = ActionView::TestController.new
    # FIXME a simple stub won't cut it ... I guess there's something seriously
    # wrong with the memoization in asset_tags somewhere
    (class << @controller; self; end).class_eval do 
      def site; @site ||= Site.first; end
    end

    theme_dir     = "#{RAILS_ROOT}/themes/site-#{@site.id}/theme-1"
    @logo         = "#{theme_dir}/images/logo.png"
    @effects      = "#{theme_dir}/javascripts/effects.js"
    @more_effects = "#{theme_dir}/javascripts/more-effects.js"
    @styles       = "#{theme_dir}/stylesheets/styles.css"
    @more_styles  = "#{theme_dir}/stylesheets/more-styles.css"
    
    [@logo, @effects, @more_effects, @styles, @more_styles].each do |asset|
      FileUtils.mkdir_p File.dirname(asset)
      FileUtils.touch asset
    end
  end

  def teardown
    super
    Site.multi_sites_enabled = @old_multi_site_enabled
    %w(themes/site-1/ public/themes/ public/cache/).each do |dir|
      FileUtils.rm_r "#{RAILS_ROOT}/#{dir}" if File.exists?("#{RAILS_ROOT}/#{dir}")
    end
  end
  
  describe "theme_image_tag" do
    action { @tag = theme_image_tag('theme-1', 'logo.png') }
    
    with :single_site_enabled do
      it "generates a tag linking to '/themes/theme-1/images/logo.png'" do
        @tag.should have_tag('img[src^=?]', '/themes/theme-1/images/logo.png')
      end
      
      it "makes sure the image file was copied to the public path" do
        "#{RAILS_ROOT}/public/themes/theme-1/images/logo.png".should be_file
      end
    end

    with :multi_sites_enabled do
      it "generates a tag linking to '/themes/theme-1/images/logo.png'" do
        @tag.should have_tag('img[src^=?]', '/themes/theme-1/images/logo.png')
      end
      
      it "makes sure the image file was copied to the public path" do
        "#{RAILS_ROOT}/public/cache/#{@site.perma_host}/themes/theme-1/images/logo.png".should be_file
      end
    end
  end
  
  describe "theme_javascript_include_tag" do
    action { @tag = theme_javascript_include_tag('theme-1', 'effects', 'more-effects', :cache => 'foo') }
    
    with :single_site_enabled do
      with :perform_caching_disabled do
        it "generates a tag linking to '/themes/theme-1/javascripts/effects.js'" do
          @tag.should have_tag('script[src^=?]', '/themes/theme-1/javascripts/effects.js')
          @tag.should have_tag('script[src^=?]', '/themes/theme-1/javascripts/more-effects.js')
        end
      
        it "makes sure the asset file was copied to the public path" do
          "#{RAILS_ROOT}/public/themes/theme-1/javascripts/effects.js".should be_file
        end
      end

      with :perform_caching_enabled do
        with 'no cache argument given' do
          action { @tag = theme_javascript_include_tag('theme-1', 'effects', 'more-effects') }
          
          it "generates a tag linking to '/themes/theme-1/javascripts/effects.js'" do
            @tag.should have_tag('script[src^=?]', '/themes/theme-1/javascripts/effects.js')
            @tag.should have_tag('script[src^=?]', '/themes/theme-1/javascripts/more-effects.js')
          end
      
          it "makes sure the asset file was copied to the public path" do
            "#{RAILS_ROOT}/public/themes/theme-1/javascripts/effects.js".should be_file
          end
        end
        
        with 'a cache => true argument given' do
          action { @tag = theme_javascript_include_tag('theme-1', 'effects', 'more-effects', :cache => true) }
          
          it "generates a tag linking to '/themes/theme-1/javascripts/all.js'" do
            @tag.should have_tag('script[src^=?]', '/themes/theme-1/javascripts/all.js')
          end
      
          it "makes sure the asset file was copied to the public path" do
            "#{RAILS_ROOT}/public/themes/theme-1/javascripts/all.js".should be_file
          end
        end
        
        with 'a cache => :foo argument given' do
          it "generates a tag linking to '/themes/theme-1/javascripts/foo.js'" do
            @tag.should have_tag('script[src^=?]', '/themes/theme-1/javascripts/foo.js')
          end
      
          it "makes sure the asset file was copied to the public path" do
            "#{RAILS_ROOT}/public/themes/theme-1/javascripts/foo.js".should be_file
          end
        end
      end
    end

    with :multi_sites_enabled do
      with :perform_caching_disabled do
        it "generates a tag linking to '/themes/theme-1/javascripts/effects.js'" do
          @tag.should have_tag('script[src^=?]', '/themes/theme-1/javascripts/effects.js')
          @tag.should have_tag('script[src^=?]', '/themes/theme-1/javascripts/more-effects.js')
        end
      
        it "makes sure the asset file was copied to the public path" do
          "#{RAILS_ROOT}/public/cache/#{@site.perma_host}/themes/theme-1/javascripts/effects.js".should be_file
        end
      end

      with :perform_caching_enabled do
        with 'no cache argument given' do
          action { @tag = theme_javascript_include_tag('theme-1', 'effects', 'more-effects') }
          
          it "generates a tag linking to '/themes/theme-1/javascripts/effects.js'" do
            @tag.should have_tag('script[src^=?]', '/themes/theme-1/javascripts/effects.js')
            @tag.should have_tag('script[src^=?]', '/themes/theme-1/javascripts/more-effects.js')
          end
      
          it "makes sure the asset file was copied to the public path" do
            "#{RAILS_ROOT}/public/cache/#{@site.perma_host}/themes/theme-1/javascripts/effects.js".should be_file
          end
        end
        
        with 'a cache => true argument given' do
          action { @tag = theme_javascript_include_tag('theme-1', 'effects', 'more-effects', :cache => true) }
          
          it "generates a tag linking to '/themes/theme-1/javascripts/all.js'" do
            @tag.should have_tag('script[src^=?]', '/themes/theme-1/javascripts/all.js')
          end
      
          it "makes sure the asset file was copied to the public path" do
            "#{RAILS_ROOT}/public/cache/#{@site.perma_host}/themes/theme-1/javascripts/all.js".should be_file
          end
        end
        
        with 'a cache => :foo argument given' do
          it "generates a tag linking to '/themes/theme-1/javascripts/foo.js'" do
            @tag.should have_tag('script[src^=?]', '/themes/theme-1/javascripts/foo.js')
          end
      
          it "makes sure the asset file was copied to the public path" do
            "#{RAILS_ROOT}/public/cache/#{@site.perma_host}/themes/theme-1/javascripts/foo.js".should be_file
          end
        end
      end
    end
  end
  
  describe "theme_stylesheet_link_tag" do
    action { @tag = theme_stylesheet_link_tag('theme-1', 'styles', 'more-styles', :cache => 'foo') }
    
    with :single_site_enabled do
      with :perform_caching_disabled do
        it "generates a tag linking to '/themes/theme-1/stylesheets/styles.css'" do
          @tag.should have_tag('link[href^=?]', '/themes/theme-1/stylesheets/styles.css')
          @tag.should have_tag('link[href^=?]', '/themes/theme-1/stylesheets/more-styles.css')
        end
      
        it "makes sure the asset file was copied to the public path" do
          "#{RAILS_ROOT}/public/themes/theme-1/stylesheets/styles.css".should be_file
        end
      end

      with :perform_caching_enabled do
        with 'no cache argument given' do
          action { @tag = theme_stylesheet_link_tag('theme-1', 'styles', 'more-styles') }
          
          it "generates a tag linking to '/themes/theme-1/stylesheets/styles.css'" do
            @tag.should have_tag('link[href^=?]', '/themes/theme-1/stylesheets/styles.css')
            @tag.should have_tag('link[href^=?]', '/themes/theme-1/stylesheets/more-styles.css')
          end
      
          it "makes sure the asset file was copied to the public path" do
            "#{RAILS_ROOT}/public/themes/theme-1/stylesheets/styles.css".should be_file
          end
        end
        
        with 'a cache => true argument given' do
          action { @tag = theme_stylesheet_link_tag('theme-1', 'styles', 'more-styles', :cache => true) }
          
          it "generates a tag linking to '/themes/theme-1/stylesheets/all.css'" do
            @tag.should have_tag('link[href^=?]', '/themes/theme-1/stylesheets/all.css')
          end
      
          it "makes sure the asset file was copied to the public path" do
            "#{RAILS_ROOT}/public/themes/theme-1/stylesheets/all.css".should be_file
          end
        end
        
        with 'a cache => :foo argument given' do
          it "generates a tag linking to '/themes/theme-1/stylesheets/foo.css'" do
            @tag.should have_tag('link[href^=?]', '/themes/theme-1/stylesheets/foo.css')
          end
      
          it "makes sure the asset file was copied to the public path" do
            "#{RAILS_ROOT}/public/themes/theme-1/stylesheets/foo.css".should be_file
          end
        end
      end
    end

    with :multi_sites_enabled do
      with :perform_caching_disabled do
        it "generates a tag linking to '/themes/theme-1/stylesheets/styles.css'" do
          @tag.should have_tag('link[href^=?]', '/themes/theme-1/stylesheets/styles.css')
          @tag.should have_tag('link[href^=?]', '/themes/theme-1/stylesheets/more-styles.css')
        end
      
        it "makes sure the asset file was copied to the public path" do
          "#{RAILS_ROOT}/public/cache/#{@site.perma_host}/themes/theme-1/stylesheets/styles.css".should be_file
        end
      end

      with :perform_caching_enabled do
        with 'no cache argument given' do
          action { @tag = theme_stylesheet_link_tag('theme-1', 'styles', 'more-styles') }
          it "generates a tag linking to '/themes/theme-1/stylesheets/styles.css'" do
            @tag.should have_tag('link[href^=?]', '/themes/theme-1/stylesheets/styles.css')
            @tag.should have_tag('link[href^=?]', '/themes/theme-1/stylesheets/more-styles.css')
          end
      
          it "makes sure the asset file was copied to the public path" do
            "#{RAILS_ROOT}/public/cache/#{@site.perma_host}/themes/theme-1/stylesheets/styles.css".should be_file
          end
        end
        
        with 'a cache => true argument given' do
          action { @tag = theme_stylesheet_link_tag('theme-1', 'styles', 'more-styles', :cache => true) }
          
          it "generates a tag linking to '/themes/theme-1/stylesheets/all.css'" do
            @tag.should have_tag('link[href^=?]', '/themes/theme-1/stylesheets/all.css')
          end
      
          it "makes sure the asset file was copied to the public path" do
            "#{RAILS_ROOT}/public/cache/#{@site.perma_host}/themes/theme-1/stylesheets/all.css".should be_file
          end
        end
        
        with 'a cache => :foo argument given' do
          it "generates a tag linking to '/themes/theme-1/stylesheets/foo.css'" do
            @tag.should have_tag('link[href^=?]', '/themes/theme-1/stylesheets/foo.css')
          end
      
          it "makes sure the asset file was copied to the public path" do
            "#{RAILS_ROOT}/public/cache/#{@site.perma_host}/themes/theme-1/stylesheets/foo.css".should be_file
          end
        end
      end
    end
  end
end