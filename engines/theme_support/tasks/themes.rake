desc "Removes the cached (public) images/javascript/stylesheets themes folders"
task :theme_remove_cache do
  ['images', 'javascripts', 'stylesheets'].each do |type|
    path = "#{RAILS_ROOT}/public/#{type}/themes"
    puts "Removing #{path}"
    FileUtils.rm_r path, :force => true
  end
end