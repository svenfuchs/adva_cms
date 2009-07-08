class UpgradePaperclipPaths < ActiveRecord::Migration
  include 
  def self.up
    sites = Site.all
      sites.each do |site|
        # Old paperclip directories
        old_assets_dir = "#{RAILS_ROOT}/public/assets"
        old_photos_dir = "#{RAILS_ROOT}/public/photos"
        old_themes_dir = "#{RAILS_ROOT}/public/themes"
        old_photos_dir_multisite = "#{RAILS_ROOT}/public/sites/site-#{site.perma_host}/photos"
        old_themes_dir_multisite = "#{RAILS_ROOT}/public/themes/site-#{site.id}"
        
        # New paperclip directory
        site_upload_dir = "#{RAILS_ROOT}/public/sites/site-#{site.id}"
        FileUtils.mkdir_p(site_upload_dir) unless File.exists?(site_upload_dir)
        
        # Copy old files to new location
        p "Starting file copy ..."
        FileUtils.cp_r("#{old_assets_dir}/.", site_upload_dir + '/assets', :verbose => true) if File.exists?(old_assets_dir)
        FileUtils.cp_r("#{old_photos_dir}/.", site_upload_dir + '/photos', :verbose => true) if File.exists?(old_photos_dir)
        FileUtils.cp_r("#{old_themes_dir}/.", site_upload_dir + '/themes', :verbose => true) if File.exists?(old_themes_dir)
        FileUtils.cp_r("#{old_photos_dir_multisite}/.", site_upload_dir + '/photos', :verbose => true) if File.exists?(old_photos_dir_multisite)
        FileUtils.cp_r("#{old_themes_dir_multisite}/.", site_upload_dir + '/themes', :verbose => true) if File.exists?(old_themes_dir_multisite)
        p "Cleanup the new themes directory..."
        FileUtils.rm_rf(site_upload_dir + "/themes/site-#{site.id}", :verbose => true) if File.exists?(site_upload_dir + "/themes/site-#{site.id}")
    end
  end
  
  def self.down
  end
end