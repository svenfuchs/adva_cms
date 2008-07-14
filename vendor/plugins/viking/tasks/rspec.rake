# begin
#   require 'spec'
# rescue LoadError
#   require 'rubygems'
#   require 'spec'
# end
# begin
#   require 'spec/rake/spectask'
# rescue LoadError
#   puts "To use RSpec for testing you must install its gem:\n\tgem install rspec"
#   exit(0)
# end
# 
# SPEC_OPTS_FILE = [
#     "-O", 
#     File.join(File.dirname(__FILE__), "..", "spec", "spec.opts")
#   ].join(" ")
# 
# desc "Run all specs"
# Spec::Rake::SpecTask.new 'spec' do |t|
#   t.spec_files = FileList["spec/**/*_spec.rb"]
#   t.spec_opts  = [SPEC_OPTS_FILE]
# end
# 
# desc "Run all specs with RCov"
# Spec::Rake::SpecTask.new 'specs_with_rcov' do |t|
#   t.spec_opts  = [SPEC_OPTS_FILE]
#   t.spec_files = FileList["spec/**/*_spec.rb"]
#   t.rcov       = true
#   t.rcov_opts  = ['--exclude', 'spec']
# end