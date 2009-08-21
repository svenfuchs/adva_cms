module UrlHistory
  class Entry < ActiveRecord::Base
    set_table_name 'url_history_entries'
    serialize :params
    
    belongs_to :resource, :polymorphic => true
    
    class << self
      def recent_by_url(url)
        find(:first, :conditions => ['url = ?', url], :order => 'id DESC')
      end
    end
    
    def updated_params
      if resource && resource.respond_to?(:update_url_history_params)
        resource.update_url_history_params(params.clone)
      else
        params
      end
    end
  end
end
