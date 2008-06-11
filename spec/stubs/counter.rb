define Counter do
  methods :count => 2,
          :increment! => nil,
          :decrement! => nil,
          :set => nil
          
  instance :counter
end

scenario :counter do 
end