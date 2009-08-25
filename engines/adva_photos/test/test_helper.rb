require File.expand_path(File.dirname(__FILE__) + '/../../adva_cms/test/test_helper')

module PhotoTestHelper
  def photo_fixture
    File.new "#{File.dirname(__FILE__)}/fixtures/rails.png"
  end

  def create_photo(attributes = {})
    defaults = { :section => Album.first, :title => 'that photo', :data => photo_fixture, :author => User.first }
    Photo.create! defaults.merge(attributes)
  end
end


