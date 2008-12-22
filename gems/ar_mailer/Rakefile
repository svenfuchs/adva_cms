require 'rubygems'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'rake/rdoctask'

$:.unshift(File.expand_path(File.dirname(__FILE__) + '/lib'))

require './lib/action_mailer/ar_sendmail'
 
ar_mailer_gemspec = Gem::Specification.new do |s|
  s.name = %q{ar_mailer}
  s.version = ActionMailer::ARSendmail::VERSION
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eric Hodel"]
  s.date = %q{2008-07-04}
  s.default_executable = %q{ar_sendmail}
  s.description = %q{Even delivering email to the local machine may take too long when you have to send hundreds of messages.  ar_mailer allows you to store messages into the database for later delivery by a separate process, ar_sendmail.}
  s.email = %q{drbrain@segment7.net}
  s.executables = ["ar_sendmail"]
  s.extra_rdoc_files = ["History.txt", "LICENSE.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "LICENSE.txt", "Manifest.txt", "README.txt", "Rakefile", "bin/ar_sendmail", "lib/action_mailer/ar_mailer.rb", "lib/action_mailer/ar_sendmail.rb", "lib/smtp_tls.rb", "share/bsd/ar_sendmail", "share/linux/ar_sendmail", "share/linux/ar_sendmail.conf", "test/action_mailer.rb", "test/test_armailer.rb", "test/test_arsendmail.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://seattlerb.org/ar_mailer}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{seattlerb}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{A two-phase delivery agent for ActionMailer}
  s.test_files = ["test/test_armailer.rb", "test/test_arsendmail.rb"]
end 

Rake::GemPackageTask.new(ar_mailer_gemspec) do |pkg|
  pkg.gem_spec = ar_mailer_gemspec
end
 
namespace :gem do
  namespace :spec do
    desc "Update ar_mailer.gemspec"
    task :generate do
      File.open("ar_mailer.gemspec", "w") do |f|
        f.puts(ar_mailer_gemspec.to_ruby)
      end
    end
  end
end
 
desc "Build packages and install"
task :install => :package do
  sh %{sudo gem install --local pkg/ar_mailer-#{ActionMailer::ARSendmail::VERSION}}
end

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the ar_mailer gem.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/**/test_*.rb'
  t.verbose = true
end
