class Newsletter < ActiveRecord::Base
  has_many :issues

  def draft?
    false
  end
end
