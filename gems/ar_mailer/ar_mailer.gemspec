Gem::Specification.new do |s|
  s.name = %q{ar_mailer}
  s.version = "1.4.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Calvin Yu", "Eric Hodel"]
  s.date = %q{2008-11-30}
  s.default_executable = %q{ar_sendmail}
  s.description = %q{Even delivering email to the local machine may take too long when you have to send hundreds of messages.  ar_mailer allows you to store messages into the database for later delivery by a separate process, ar_sendmail.}
  s.email = %q{calvin@skribit.com}
  s.executables = ["ar_sendmail"]
  s.extra_rdoc_files = ["History.txt", "LICENSE.txt", "Manifest.txt", "README.rdoc"]
  s.files = ["History.txt","LICENSE.txt", "Manifest.txt", "README.rdoc", "Rakefile", "bin/ar_sendmail", "lib/ar_mailer.rb", "lib/action_mailer/ar_mailer.rb", "lib/action_mailer/ar_sendmail.rb", "share/bsd/ar_sendmail", "share/linux/ar_sendmail", "share/linux/ar_sendmail.conf", "test/action_mailer.rb", "test/test_armailer.rb", "test/test_arsendmail.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://seattlerb.org/ar_mailer}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{seattlerb}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{A two-phase delivery agent for ActionMailer}
  s.test_files = ["test/test_armailer.rb", "test/test_arsendmail.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
    else
    end
  else
  end
end
