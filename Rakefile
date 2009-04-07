require 'thread'
require 'fileutils'
require 'webrick'
require 'erb'
require File.expand_path(File.dirname(__FILE__) + "/engines/adva_cms/test/javascript/lib/jstest")
include WEBrick

namespace :test do
  namespace :js do
    task :run => :prepare do
      t = Thread.new { @server.start }

      @browsers.each do |browser|
        if browser.supported?
          browser.setup
          puts "\nStarted tests in #{browser}."

          @tests.each do |test|
            browser.visit(test)
            # TODO collect results in shell
          end

          # TODO verify why it doesn't teardown properly
          browser.teardown
        else
          puts "\nSkipping #{browser}, not supported on this OS."
        end
      end

      # TODO clean tmp paths before quit
      t.join
    end
    
    task :prepare => [ :browsers, :plugins, :templates, :server ]

    task :browsers do
      # TODO run all browsers by default
      # TODO accepts from ENV var: BROWSERS=safari,firefox
      @browsers = [ FirefoxBrowser.new ]
    end

    task :plugins do
      # TODO run tests for all plugins
      # TODO accepts from ENV var: PLUGINS=adva_calendar,adva_assets
      @plugins = { "adva_calendar" => File.expand_path(File.dirname(__FILE__) + "/engines/adva_calendar") }
    end
    
    task :templates do
      template = File.new(File.expand_path(File.dirname(__FILE__) + "/engines/adva_cms/test/javascript/templates/test_case.erb")).read
      template = ERB.new(template)
      @tests = []
      @plugins.each do |plugin, plugin_root|
        test_path = "#{plugin_root}/test/javascript"
        temp_test_path = "#{test_path}/tmp"
        FileUtils.mkdir_p "#{temp_test_path}/unit"
        FileUtils.mkdir_p "#{temp_test_path}/functional"
        Dir["#{test_path}/**/*_test.js"].each do |test_case|
          @plugin     = plugin
          @title      = File.basename(test_case, ".js")
          @test_suite = File.new(test_case).read
          @target = test_case.gsub(%r{#{test_path}/(unit|functional)/}, "")
          @target = "/#{plugin}/javascripts/#{plugin}/#{@target}"
          test_type = test_case =~ /unit/ ? "unit" : "functional"
          File.open("#{temp_test_path}/#{test_type}/#{@title}.html", 'w') { |f| f.write(template.result) }
          @tests << "http://localhost:2333/#{plugin}/test/#{test_type}/#{@title}.html"
        end
      end
    end
    
    task :server do
      document_root = File.expand_path(File.dirname(__FILE__) + "/engines/adva_cms/test/javascript/assets")
      @server = HTTPServer.new(:Port => 2333, :DocumentRoot => document_root)
      
      @plugins.each do |plugin, plugin_root|
        @server.mount "/#{plugin}",      NonCachingFileHandler, "#{plugin_root}/public"
        @server.mount "/#{plugin}/test", NonCachingFileHandler, "#{plugin_root}/test/javascript/tmp"
      end
      
      trap("INT") { @server.shutdown }
    end
  end
end
