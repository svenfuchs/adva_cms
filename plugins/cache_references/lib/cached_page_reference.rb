class CachedPageReference < ActiveRecord::Base
  belongs_to :cached_page
  belongs_to :object, :polymorphic => true
  
  class << self
    def initialize_with(object, method = nil)
      new :object_type => object.class.name, :object_id => object.id, :method => method.to_s
    end
  end
  
  def ==(other)
    self.cached_page_id == other.cached_page_id &&
    self.object_type == other.object_type &&
    self.object_id == other.object_id &&
    self.method == other.method
  end
end