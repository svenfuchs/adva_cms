class AssetAssignment < ActiveRecord::Base
  belongs_to :content, :counter_cache => 'assets_count'
  belongs_to :asset
  # acts_as_list :scope => :content_id
  validates_presence_of :content_id, :asset_id
  validate_on_create :check_for_dupe_content_and_asset

  protected
    def check_for_dupe_content_and_asset
      unless self.class.count(:all, :conditions => ['content_id = ? and asset_id = ?', content_id, asset_id]).zero?
        errors.add_to_base("Cannot have a duplicate assignment for this content and asset")
      end
    end
end
