class Array
  def to_path(sep = '/')
    reject { |s| s.blank? }.join(sep)
  end
end
