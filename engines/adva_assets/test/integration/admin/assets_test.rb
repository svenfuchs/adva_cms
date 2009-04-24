require File.expand_path(File.dirname(__FILE__) + '/../../test_helper' )

module IntegrationTests
  class AdminAssetsTest < ActionController::IntegrationTest
    include AssetsTestHelper

    def setup
      super
      @site = Site.find_by_name 'site with pages'
      use_site! @site
      @image = image_fixture.path
    end

    # FIXME test assigning assets to the bucket and assigning assets to a content

    test "Admin reviews the assets list, creates a new asset, edits it and deletes it" do
      login_as_admin
      view_assets_list
      # TODO: re-enable when webrat bug is fixed
      # create_a_new_asset
      # edit_the_asset
      # delete_the_asset
    end

    def view_assets_list
      visit "/admin/sites/#{@site.id}" # FIXME webrat doesn't automatically redirect us here?
      click_link 'Assets'
      renders_template 'admin/assets/index'
    end

    def create_a_new_asset
      click_link 'New'
      renders_template 'admin/assets/new'

      fill_in 'assets[][title]',    :with => 'the new asset'
      fill_in 'assets[][tag_list]', :with => 'foo bar'
      attach_file 'assets[][data]', @image
      click_button 'Upload'

      request.url.should =~ %r(/admin/sites/\d+/assets$)
      "#{Asset.root_dir}/assets/rails.png".should be_file
    end

    # TODO: maybe add a test that uploads multiple assets at once?

    def edit_the_asset
      asset = Asset.find_by_title('the new asset')
      click_link "Edit"
      fill_in 'title', :with => 'the updated asset'
      click_button 'Save Asset'
      request.url.should =~ %r(/admin/sites/\d+/assets$)
    end

    def delete_the_asset
      asset = Asset.find_by_title('the updated asset')
      click_link "Delete"
      request.url.should =~ %r(/admin/sites/\d+/assets$)
      "#{Asset.root_dir}/assets/rails.png".should_not be_file
    end
  end
end