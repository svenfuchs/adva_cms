ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../../config/environment")

$:.unshift File.expand_path(RAILS_ROOT + "/vendor/gems/rspec-rails-1.1.4/lib")
$:.unshift File.expand_path(RAILS_ROOT + "/vendor/gems/rspec-1.1.4/lib")

require 'spec'
require 'spec/rails'
require 'spec/story'
require 'spec/mocks'
require 'spec/rails/story_adapter'
require 'active_record/fixtures'
require 'factories-and-workers'

require 'webrat/rails'
Webrat.configuration.open_error_files = false

require 'globalize/i18n/missing_translations_raise_handler'
I18n.exception_handler = :missing_translations_raise_handler

ActionController::Base.page_cache_directory = RAILS_ROOT + '/tmp/cache'
ActionController::Base.perform_caching = true

Theme.root_dir = RAILS_ROOT + '/tmp'
Asset.base_dir = RAILS_ROOT + '/tmp/assets'

cache_dirs = ActionController::Base.page_cache_directory, Theme.base_dir, Asset.base_dir
cache_dirs.each{|dir| FileUtils.rm_rf dir unless dir.empty? or dir == '/' }
FileUtils.rm_rf Dir[RAILS_ROOT + "/tmp/webrat*"]
# FileUtils.rm_rf Dir[RAILS_ROOT + "/tmp/stories"]

asset_target = RAILS_ROOT + "/public/images/rails.test.png"
File.unlink asset_target if File.exists? asset_target
File.cp RAILS_ROOT + "/vendor/adva/engines/adva_cms/stories/assets/rails.test.png", asset_target


Spec::Runner.configure do |config|
  config.include Spec::Story
end

include FactoriesAndWorkers::Factory

now = Time.parse '2008-01-01 12:00:00 UTC'
Time.stub!(:now).and_return now
Time.zone.stub!(:now).and_return now

def factories(*names)
  names.each do |name|
    require File.expand_path(File.dirname(__FILE__) + "/factories/#{name}")
  end
end

def steps(*names)
  step_dir = File.expand_path(File.dirname(__FILE__) + '/steps')
  if names.first == :all
    Dir["#{step_dir}/**/*.rb"].uniq.map do |path|
      require path
      File.basename(path).gsub(/#{File.extname(path)}$/, '').to_sym
    end
  else
    names.each { |name| require step_dir + "/#{name}" }
  end
end

Spec::Rails::Matchers.module_eval do
  def have_form_putting_to(url_or_path)
    return simple_matcher("have a form submitting via PUT to '#{url_or_path}'") do |response|
      have_tag("form[method=post][action=#{url_or_path}]").matches?(response)
      have_tag("input[name=_method][type=hidden][value=put]").matches?(response)
    end
  end
end
