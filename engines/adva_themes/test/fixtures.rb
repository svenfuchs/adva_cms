site = Site.find_by_name 'site with sections'

theme = site.themes.create! :name     => 'a theme',
                            :version  => '1.0.0',
                            :homepage => 'http://homepage.org',
                            :author   => 'author',
                            :summary  => 'summary'


# theme.templates.create!     :name  => 'template.html.erb',
#                             :data => File.new("#{File.dirname(__FILE__)}/fixtures/template.html.erb")
# 
# theme.assets.create!        :name  => 'that-rails-log.png',
#                             :data => File.new("#{File.dirname(__FILE__)}/fixtures/rails.png")
