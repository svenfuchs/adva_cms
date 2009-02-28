class AssetAssignment < ActiveRecord::Base
  belongs_to :content # FIXME :counter_cache => 'assets_count'
  belongs_to :asset

  validates_presence_of :content_id, :asset_id
  validate_on_create :check_for_dupe_content_and_asset

  protected
    def check_for_dupe_content_and_asset
      unless self.class.count(:all, :conditions => ['content_id = ? and asset_id = ?', content_id, asset_id]).zero?
        errors.add_to_base I18n.t(:'adva.assets.validation.duplicate')
      end
    end
end
