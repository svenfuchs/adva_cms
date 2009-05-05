#!/usr/bin/ruby1.8
require 'fileutils'

application = 'adva-cms'
target_root = '/tmp'
target      = "#{target_root}/#{application}"

puts "Cleaning up the previous deployment ..."
FileUtils.rm_rf(target, :secure => true) if File.exists?(target)
FileUtils.cd(target_root)

puts "Setting up the test application ..."
system("rails -q #{application} -m /srv/integrity/scripts/adva-cms.ci.template.rb")
FileUtils.cd(target)

puts "Running the tests ..."

test_result = system("vendor/adva/script/test vendor/adva/engines/ -p")
test_result ? Kernel.exit(0) : Kernel.exit(1) # Test script should actually return correct exit code already
