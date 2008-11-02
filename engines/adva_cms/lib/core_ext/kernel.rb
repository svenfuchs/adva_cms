Kernel.class_eval do 
  def with_swap(var, value)
    value, var = var, value
    yield
    value, var = var, value
  end
end