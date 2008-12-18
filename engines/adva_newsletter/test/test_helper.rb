require File.expand_path(File.join(File.dirname(__FILE__), '../../adva_cms/test', 'test_helper' ))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'factories', 'factories'))

#TODO move to more global place
def assert_flash(message)
  regexp = Regexp.new(message.gsub(' ', '\\\+'))
  assert cookies['flash'] =~ regexp,
    "Flash message is wrong or missing:\nWe should get flash message: #{message} #Regex: #{regexp}\nBUT we got cookie what does not match to our regex: #{cookies['flash']}"
end
