require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class I18nTest < ActiveSupport::TestCase
  test "/config/locale/rails/de.yml is included in the I18n load_path" do
    paths = I18n.load_path.map{|path| path.gsub(%r(.*/adva_cms/), '') }
    paths.should include('locale/rails/de.yml')
  end
  
  test "correctly looks up english ar errormessage :invalid" do
    I18n.t(:"activerecord.errors.messages.invalid").should == "is invalid"
  end
  
  test "correctly looks up german ar errormessage :invalid" do
    I18n.t(:"activerecord.errors.messages.invalid", :locale => :de).should == "ist nicht gültig"
  end
end
