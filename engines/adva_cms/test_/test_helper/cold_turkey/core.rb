module With
  class Group
    def it_changes(expressions, message = nil)
      expressions.each do |expression, difference|
        before { record_before_state(expression) }
        assertion "it changes #{expression} by #{difference}" do
          assert_state_change(expression, difference, message)
        end
      end
    end
    
    def it_does_not_change(*expressions)
      expressions.each do |expression|
        before { record_before_state(expression) }
        assertion "it does not change #{expression}" do
          assert_no_state_change(expression)
        end
      end
    end
  end
end

class ActionController::TestCase
  @@variable_types = {:headers => :to_s, :flash => nil, :session => nil, :flash_cookie => nil}

  def it_maps(method, path, params)
    assert_recognizes params, {:path => path, :method => method }
  end

  def it_generates(path, params)
    assert_generates path, params
  end

  def it_renders(render_method, *args, &block)
    send("it_renders_#{render_method}", *args, &block)
  end

  def it_renders_blank(options = {})
    asserts_status options[:status]
    assert @response.body.strip.blank?
  end

  def it_renders_template(template_name, options = {})
    assert_status options[:status]
    assert_content_type options[:format]
    assert_template template_name.to_s
  end

  def assert_content_type(type = :html)
    mime = Mime::Type.lookup_by_extension((type || :html).to_s)
    assert_equal mime, @response.content_type, "Renders with Content-Type of #{@response.content_type}, not #{mime}"
  end

  def assert_status(status)
    case status
    when String, Fixnum
      assert_equal status.to_s, @response.code, "Renders with status of #{@response.code.inspect}, not #{status}"
    when Symbol
      code_value = ActionController::StatusCodes::SYMBOL_TO_STATUS_CODE[status]
      assert_equal code_value.to_s, @response.code, "Renders with status of #{@response.code.inspect}, not #{code_value.inspect} (#{status.inspect})"
    else
      assert_equal "200", @response.code, "Is not successful"
    end
  end
  
  def it_saves(*names)
    names.each do |name|
      assert !assigns(name).new_record?
    end
  end

  def it_does_not_save(*names)
    names.each do |name|
      assert assigns(name).new_record?
    end
  end

  def it_assigns(*names)
    names.each do |name|
      if name.is_a?(Symbol)
        it_assigns name => name # go forth and recurse!
      elsif name.is_a?(Hash)
        name.each do |key, value|
          if @@variable_types.key?(key) then send("it_assigns_#{key}", value)
          else it_assigns_example_values(key, value) end
        end
      end
    end
  end

  def it_assigns_example_values(name, value)
    case value
    when :not_nil
      assert_not_nil assigns(name), "@#{name} is nil"
    when :undefined
      assert !@controller.send(:instance_variables).include?("@#{name}"), "@#{name} is defined"
    when Symbol
      if (instance_variable = instance_variable_get("@#{value}")).nil?
        assert_not_nil assigns(name)
      else
        assert_equal instance_variable, assigns(name)
      end
    end
  end

  @@variable_types.each do |collection_type, collection_op|
    public
      define_method "it_assigns_#{collection_type}" do |values|
        values.each do |key, value|
          send("it_assigns_#{collection_type}_values", key, value)
        end
      end
  
    protected
      define_method "it_assigns_#{collection_type}_values" do |key, value|
        key = key.send(collection_op) if collection_op
        collection = @response.send(collection_type)
        case value
          when nil
            assert_nil collection[key]
          when :not_nil
            assert_not_nil collection[key]
          when :undefined
            assert !collection.include?(key), "#{collection_type} includes #{key}"
          when Proc
            assert_equal instance_eval(&value), collection[key]
          else
            assert_equal value, collection[key]
        end
      end
  end
  
  def it_redirects_to(&path)
    assert_redirected_to instance_eval(&path)
  end

  protected
  
    def record_before_state(expression)
      @before_states ||= {}
      @before_states[expression] = instance_eval(expression)
    end
  
    def assert_state_change(expression, difference, message = nil)
      expected = @before_states[expression] + difference
      result   = instance_eval(expression)
      message  = [message, "expected #{expression} to be #{expected} but was #{result}"]
    
      assert_equal expected, result, message.compact.join("\n")
    end
  
    def assert_no_state_change(expression)
      expected = @before_states[expression]
      result   = instance_eval(expression)
      message  = "expected #{expression} to not change, but changed from #{expected} to #{result}"
    
      assert_equal expected, result, message
    end
end