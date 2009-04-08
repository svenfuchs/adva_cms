require File.expand_path(File.dirname(__FILE__) + "/engines/adva_cms/test/javascript/lib/jstest")

namespace :test do
  desc "Runs all the JavaScript unit tests and collects the results"
  AdvaJavaScriptTestTask.new(:js) do |t|
    tests_to_run     = ENV['TESTS']    && ENV['TESTS'].split(',')
    browsers_to_test = ENV['BROWSERS'] && ENV['BROWSERS'].split(',')

    t.prepare_plugins(tests_to_run)
    t.prepare_tests
    t.mount("/", File.expand_path(File.dirname(__FILE__) + "/engines/adva_cms/test/javascript/assets"))
    t.mount_plugins

    %w( safari firefox ie konqueror opera ).each do |browser|
      t.browser(browser.to_sym) unless browsers_to_test && !browsers_to_test.include?(browser)
    end
  end
end
