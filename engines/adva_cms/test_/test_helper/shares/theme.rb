class Test::Unit::TestCase
  # FIXME ... should be on mechanist blueprints
  def valid_theme_params
    { :name      => 'Theme 1',
      :version    => '1.0.0', 
      :homepage   => 'http://homepage.org', 
      :author     => 'author', 
      :summary    => 'summary' }
  end

  share :valid_theme_params do
    before do
      @params = { :theme => valid_theme_params }
    end
  end
  
  share :invalid_theme_params do
    before do
      @params = { :theme => valid_theme_params.update(:name => '') }
    end
  end

  share :a_theme do
    before do 
      @site = Site.make
      @theme = @site.themes.build valid_theme_params
      @theme.save!
    end
  end
end