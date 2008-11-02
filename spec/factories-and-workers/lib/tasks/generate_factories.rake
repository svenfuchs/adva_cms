desc "Generate factory templates from database schema; takes optional MODEL= argument"

namespace :factory do

  task :generate do
    require File.join( RAILS_ROOT, 'config', 'environment' )

    if arg = ENV['model'] || ENV['MODEL']
      puts Factory.generate_template( arg )
    else
      all_models = Dir.glob( File.join( RAILS_ROOT, 'app', 'models', '*.rb') ).map{|path| path[/.+\/(.+).rb/, 1] }
      all_models.select{|m| m.classify.constantize < ActiveRecord::Base}.each do |model|
        puts Factory.generate_template( model )
      end
    end
  end

end