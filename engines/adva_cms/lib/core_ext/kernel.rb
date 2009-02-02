Kernel.class_eval do 
  def with_swap(var, value)
    value, var = var, value
    yield
    value, var = var, value
  end
  
  def require_all(*patterns)
    options = patterns.last.is_a?(Hash) ? patterns.pop : {}
    patterns.map! { |pattern| "#{options[:in]}/#{pattern}"} if options[:in]
    
    Dir["{#{patterns.join(',')}}"].uniq.sort.each do |path| 
      require File.expand_path(path)
    end
  end
end
