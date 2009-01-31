Gem::Specification.new do |s|
  s.name     = "matchy"
  s.version  = "0.1.0"
  s.date     = "2008-10-05"
  s.summary  = "RSpec-esque matchers for use in Test::Unit"
  s.email    = "jeremy@entp.com"
  s.homepage = "http://github.com/jeremymcanally/matchy"
  s.description = "Hate writing assertions?  Need a little behavior-driven love in your tests?  Then matchy is for you."
  s.has_rdoc = true
  s.authors  = ["Jeremy McAnally"]
  s.files    = [
    "History.txt", 
  	"Manifest.txt", 
  	"README.rdoc", 
  	"Rakefile", 
  	"matchy.gemspec", 
    "History.txt",
    "License.txt",
    "Manifest.txt",
    "PostInstall.txt",
    "README.markdown",
    "Rakefile",
    "config/hoe.rb",
    "config/requirements.rb",
    "lib/matchy.rb",
    "lib/matchy/version.rb",
    "lib/matchy/expectation.rb",
    "lib/matchy/modals.rb",
    "lib/matchy/built_in/enumerable_expectations.rb",
    "lib/matchy/built_in/error_expectations.rb",
    "lib/matchy/built_in/operator_expectations.rb",
    "lib/matchy/built_in/truth_expectations.rb",
    "setup.rb"
  ]
  
  s.test_files = [
    "test/test_enumerable_expectations.rb",
    "test/test_error_expectations.rb",
    "test/test_expectation_base.rb",
    "test/test_operator_expectations.rb",
    "test/test_truth_expectations.rb",
    "test/test_modals.rb"
  ]

  s.rdoc_options = ["--main", "README.rdoc"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.rdoc"]
end