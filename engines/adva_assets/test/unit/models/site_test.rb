require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

module AssetTests
  class SiteTest < ActiveSupport::TestCase
    def setup
      super
      @site = Site.first
    end

    test "has many assets" do
      @site.should have_many(:assets)
    end

    test "assets.recent finds the six most recent assets" do
      mock(@site.assets).find :all, hash_including(:limit => 6)
      @site.assets.recent
    end
  end
end