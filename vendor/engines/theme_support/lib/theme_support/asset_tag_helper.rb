ActionView::Helpers::AssetTagHelper.module_eval do
  # TODO wow, this sux. patch asset_tag_helpers to use an overwriteable 
  # mattr_accessor instead of constants for directories
  def write_asset_file_contents_with_path_munging(joined_asset_path, asset_paths)
    if respond_to?(:page_cache_subdirectory)
      joined_asset_path.sub! %r(public/(stylesheets|javascripts)/), "#{page_cache_subdirectory}/#{'\1'}/"
    end
    write_asset_file_contents_without_path_munging joined_asset_path, asset_paths
  end
  alias_method_chain :write_asset_file_contents, :path_munging
end

class ActionController::Base
  def self.reset_file_exist_cache!
    @@file_exist_cache = nil
  end
end

class ActionView::Base
  def self.reset_file_exist_cache!
    @@file_exist_cache = nil
  end
end