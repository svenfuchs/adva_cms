site = Site.find_by_name 'site with pages'
# FIXME there must be better way to do this
Theme.root_dir = "#{RAILS_ROOT}/tmp"

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
