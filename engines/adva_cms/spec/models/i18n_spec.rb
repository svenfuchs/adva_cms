require File.dirname(__FILE__) + '/../spec_helper'

describe I18n do
  it "should have /config/locale/rails/de.yml in the load_path" do
    paths = I18n.load_path.map{|path| path.gsub(%r(.*/adva_cms/), '') }
    paths.should include('locale/rails/de.yml')
  end
  
  it "should correctly lookup english ar errormessage :invalid" do
    I18n.t(:"activerecord.errors.messages.invalid").should == "is invalid"
  end
  
  it "should correctly lookup german ar errormessage :invalid" do
    I18n.t(:"activerecord.errors.messages.invalid", :locale => :de).should == "ist nicht gültig"
  end
end
