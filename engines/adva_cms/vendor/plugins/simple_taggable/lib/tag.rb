class Tag < ActiveRecord::Base
  has_many :taggings

  validates_presence_of :name
  validates_uniqueness_of :name

  cattr_accessor :destroy_unused
  self.destroy_unused = true
  
  class << self
    def find_or_create_by_name(name)
      find(:first, :conditions => ["name LIKE ?", name]) || create(:name => name)
    end
  end

  def count
    read_attribute(:count).to_i
  end

  def ==(object)
    super || (object.is_a?(Tag) && name == object.name)
  end

  def to_s
    name
  end
  alias :to_param :to_s
end


