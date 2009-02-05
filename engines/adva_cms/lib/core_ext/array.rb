class Array
  def to_path(sep = '/')
    map{|s| s unless s.blank? }.compact.join(sep)
  end
end
