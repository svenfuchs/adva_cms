class Test::Unit::TestCase
  # def valid_plugin_params
  #   { :string => 'a string',
  #     :text   => 'a text' }
  # end
  # 
  # share :valid_plugin_params do
  #   before do
  #     @params = { :plugin => valid_plugin_params }
  #   end
  # end

  share :a_plugin do
    before do
      @plugin = Engines.plugins[:test_plugin].clone
      @plugin.owner = @site
      @plugin.options = { :string => 'string', :text => 'text'}
      @plugin.save!
    end
  end
end