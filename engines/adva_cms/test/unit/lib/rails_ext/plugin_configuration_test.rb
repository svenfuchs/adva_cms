require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class PluginConfigurationTest < ActiveSupport::TestCase
  def setup
    super
    @site = Site.first or flunk('could not find Site')
    @plugin = Rails.plugins[:test_plugin].clone
    @plugin.owner = @site

    Rails::Plugin::Config.delete_all
  end

  test 'registers the test_plugin' do
    @plugin.should be_instance_of(Rails::Plugin)
  end

  test 'can not access config when owner has not been set' do
    @plugin.owner = nil
    lambda { @plugin.config }.should raise_error
  end

  test 'instantiates a new configuration when first accessed' do
    config = @plugin.send(:config)
    config.should be_instance_of(Rails::Plugin::Config)
    config.new_record?.should be_true
  end

  test 'looks up existing configuration from the database' do
    @plugin.save!
    @plugin.instance_variable_set(:@config, nil)
    config = @plugin.send(:config)
    config.should be_instance_of(Rails::Plugin::Config)
    config.new_record?.should be_false
  end

  test 'returns default option values by default' do
    @plugin.string.should == 'default string'
    @plugin.text.should == 'default text'
  end
end