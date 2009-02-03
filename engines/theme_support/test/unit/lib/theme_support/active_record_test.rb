require File.dirname(__FILE__) + '/../../../test_helper'

class Something < ActiveRecord::Base
  self.abstract_class = true
  acts_as_themed :default => 'funky'
  class << self
    def columns
      @columns ||= []
    end
    def column(name, sql_type = nil, default = nil, null = true)
      columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
      reset_column_information
    end
  end
end

class ActsAsThemedTest < ActiveSupport::TestCase
  def setup
    super
    @something = Something.new
    stub(@something).id.returns 1
    stub(@something).theme_names.returns ['theme-1']
  end

  test "validate with a valid theme name" do
    @something.should be_valid
  end

  test "forbid forward slashes in the theme_name" do
    stub(@something).theme_names.returns ['etc/whatever']
    @something.should_not be_valid
  end

  test "forbid backward slashes in the theme_name" do
    stub(@something).theme_names.returns ['etc\whatever']
    @something.should_not be_valid
  end

  test "prefix theme_name with theme_dir" do
    @something.theme_paths.should == ['something-1/theme-1']
  end

  test "return 'funky' as default theme_name when no theme name set" do
    stub(@something).theme_names.returns []
    @something.theme_paths.should == ['something-1/funky']
  end

  test "delegate find through proxy class to Theme, passing theme_dir" do
    mock(Theme).find(:all, "something-1/")
    @something.themes.find(:all)
  end

  test "call Theme to find the current_theme" do
    mock(Theme).find(['theme-1'], "something-1/")
    @something.current_themes
  end

  test "return '[theme base_dir]/something-1' as a themes_path" do
    @something.themes_dir.should == "#{Theme.base_dir}/something-1/"
  end
end
