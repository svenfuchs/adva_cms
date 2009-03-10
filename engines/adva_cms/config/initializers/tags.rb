TagList.delimiter = ' '
Tag.destroy_unused = true
Tag.class_eval do 
  def to_param; name end 
end