class Test::Unit::TestCase
  def valid_theme_params
    { :name      => 'Theme 1',
      :version    => '1.0.0',
      :homepage   => 'http://homepage.org',
      :author     => 'author',
      :summary    => 'summary' }
  end

  share :a_theme do
    before do
      @theme = @site.themes.find_by_name 'a theme'
    end
  end

  share :a_theme_template do
    before do
      @file = @theme.templates.create! \
        :name  => 'template.html.erb',
        :data => File.new("#{File.dirname(__FILE__)}/fixtures/template.html.erb")
    end
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

  # image = File.new("#{File.dirname(__FILE__)}/fixtures/rails.png")

  share :valid_theme_template_params do
    before do
      @params = { :file => { :name  => 'another-template.html.erb', :data => 'the template' } }
    end
  end

  share :invalid_theme_template_params do
    before do
      @params = { :file => { :name  => 'invalid', :data => 'the template' } }
    end
  end

  share :valid_theme_upload_params do
    before do
      @params = { :files => [{ :data => ActionController::TestUploadedFile.new("#{File.dirname(__FILE__)}/fixtures/rails.png") }] }
    end
  end

  share :invalid_theme_upload_params do
    before do
      @params = { :files => [{ :data => nil }] }
    end
  end
end