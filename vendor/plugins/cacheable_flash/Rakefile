require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'fileutils'
include FileUtils

PKG_VERSION = "0.1.4"

desc 'Default: run unit tests.'
task :default => :spec

desc 'Test the cacheable_flash plugin.'
Rake::TestTask.new(:spec) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the cacheable_flash plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'CacheableFlash'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Tag the current release'
task(:tag_release) {tag_release}

desc 'Package the release as a tarball'
task(:pkg) {package_release}

def tag_release
  user = ENV['USER'] || nil
  user_part = user ? "#{user}@" : ""
  svn_path = "svn+ssh://#{user_part}rubyforge.org/var/svn/pivotalrb/cacheable_flash"
  `svn cp #{svn_path}/trunk #{svn_path}/tags/REL-#{dashed_version} -m 'Version #{PKG_VERSION}'`
end

def package_release
  dir = File.dirname(__FILE__)
  mkdir_p "#{dir}/pkg"
  files = [
    "README",
    "CHANGES",
    "init.rb",
    "install.rb",
    "uninstall.rb",
    "lib",
    "javascripts",
    "tasks",
    "test",
  ]
  files = files.collect { |f| "cacheable_flash/#{f}" }
  Dir.chdir("#{dir}/..") do
    `tar zcvf cacheable_flash/pkg/cacheable_flash-#{dashed_version}.tgz #{files.join(' ')}`
  end
end

def dashed_version
  PKG_VERSION.gsub('.', '-')
end