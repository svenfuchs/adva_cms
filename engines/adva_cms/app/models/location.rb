class Location < ActiveRecord::Base
  validates_presence_of :title
  belongs_to :site

  def oneliner
    [title, address, postcode_with_town].collect{|a| a unless a.blank? }.compact.join(', ')
  end
  
  def postcode_with_town
    [postcode, town].collect{|a| a unless a.blank? }.compact.join(' ')
  end

end
