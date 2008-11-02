require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the better_nested_set plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.test_files = ['test/preload_active_support.rb'] + FileList['test/t_*.rb'] + FileList['lib/*.rb']
  t.verbose = true
end

PKG_RDOC_OPTS = ['--main=README',
                 '--line-numbers',
                 '--charset=utf-8',
                 '--promiscuous']

desc 'Generate documentation'
Rake::RDocTask.new(:doc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'BetterNestedSet.'
  rdoc.options  = PKG_RDOC_OPTS
  rdoc.rdoc_files.include('README', 'lib/*.rb')
end