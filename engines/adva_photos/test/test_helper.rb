require File.expand_path(File.dirname(__FILE__) + '/../../adva_cms/test/test_helper')

class ActiveSupport::TestCase
  setup    :setup_photos_dir!
  teardown :clear_photos_dir!
end

module PhotoTestHelper
  def photo_fixture
    File.new "#{File.dirname(__FILE__)}/fixtures/rails.png"
  end

  def create_photo(attributes = {})
    defaults = { :section => Album.first, :title => 'that photo', :data => photo_fixture, :author => User.first }
    Photo.create! defaults.merge(attributes)
  end
end


