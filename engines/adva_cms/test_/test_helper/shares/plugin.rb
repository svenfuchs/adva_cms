class Test::Unit::TestCase
  share :a_plugin do
    before do
      @plugin = Engines.plugins[:test_plugin].clone
      @plugin.owner = @site
      @plugin.options = { :string => 'string', :text => 'text'}
      @plugin.save!
    end
  end
end