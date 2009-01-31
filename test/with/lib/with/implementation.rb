module With
  module Implementation
    def implemented_at?(file, line)
      (file.nil? || file == self.file) && (line.nil? || line.to_i == self.line) or
      respond_to?(:calls) && !calls.values.flatten.select{|call| call.implemented_at?(file, line) }.empty? or
      respond_to?(:parent) && parent && parent.implemented_at?(file, line)
    end
      
    def implementation
      @implementation ||= begin
        file, line = @block ? eval("[__FILE__, __LINE__]", @block) : [nil, nil]
        Hash[*[:file, :line].zip([file, line]).flatten]
      end
    end
    
    [:file, :line].each { |key| define_method(key) { implementation[key] } }
  end
end