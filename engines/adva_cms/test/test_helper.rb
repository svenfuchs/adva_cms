defined?(TEST_HELPER_LOADED) ? raise("can not load #{__FILE__} twice") : TEST_HELPER_LOADED = true

def rails_root
  dir = File.expand_path(File.dirname(__FILE__) + "/../..")
  while dir = File.dirname(dir) and dir != '/' do 
    return dir if File.exists?("#{dir}/config/environment.rb")
  end
end

ENV["RAILS_ENV"] = "test"
dir = File.dirname(__FILE__)
require "#{rails_root}/config/environment.rb" #File.expand_path(dir + "/../../../../../config/environment")

require 'matchy'
require 'test_help'
require 'action_view/test_case'
require 'with'
require 'with-sugar'

require 'globalize/i18n/missing_translations_raise_handler'
I18n.exception_handler = :missing_translations_raise_handler

class ActiveSupport::TestCase
  include RR::Adapters::TestUnit

  setup :start_db_transaction!
  setup :setup_page_caching!
  setup :set_locale!
  setup :ensure_single_site_mode!
  
  teardown :rollback_db_transaction!
  teardown :clear_cache_dir!
  teardown :rollback_multi_site_mode!
  
  def set_locale!
    I18n.locale = nil
    I18n.default_locale = :en
  end
  
  def stub_paperclip_post_processing!
    stub.proxy(Paperclip::Attachment).new { |attachment| stub(attachment).post_process }
  end
end

# FIXME at_exit { try to rollback any open transactions }

# include this line to test adva-cms with url_history installed
# require dir + '/plugins/url_history/init_url_history'

require_all dir + "/contexts.rb",
            dir + "/test_helper/**/*.rb"
require_all dir + "/../../*/test/contexts.rb",
            dir + "/../../*/test/test_helper/**/*.rb"

if DO_PREPARE_DATABASE
  puts 'Preparing the database ...'
  # load "#{Rails.root}/db/schema.rb"
  require_all dir + "/fixtures.rb"
  require_all dir + "/../../*/test/fixtures.rb"
end
