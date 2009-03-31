ActionController::Base.class_eval do
  class << self
    def renders_with_error_proc(error_proc_key)
      write_inheritable_attribute :default_error_proc, error_proc_key
    end
  end

  @@field_error_procs = {
    :above_field => Proc.new { |html_tag, instance|
      html_tag =~ /<label/ ? html_tag : %(<span class="error_message">#{Array(instance.error_message).to_sentence}</span>) + html_tag
    },
    :below_field => Proc.new { |html_tag, instance|
      html_tag =~ /<label/ ? html_tag : html_tag + %(<span class="error_message">#{Array(instance.error_message).to_sentence}</span>)
    }
  }
  cattr_accessor :field_error_procs
  
  def render_with_error_proc(*args, &block)
    options = args.last.is_a?(Hash) ? args.last : {}
    with_error_proc(extract_error_proc_key(options)) do
      render_without_error_proc(*args, &block)
    end
  end
  alias_method_chain :render, :error_proc unless method_defined? :render_without_error_proc

  def extract_error_proc_key(options)
    error_proc_key = options.delete(:errors) if options.is_a? Hash
    error_proc_key ||= self.class.read_inheritable_attribute(:default_error_proc)
  end

  def with_error_proc(error_proc_key)
    if error_proc_key
      raise "invalid error_proc_key: #{error_proc_key}" unless self.field_error_procs[error_proc_key]
      old_proc = ActionView::Base.field_error_proc
      ActionView::Base.field_error_proc = self.field_error_procs[error_proc_key]
      returning yield do
        ActionView::Base.field_error_proc = old_proc
      end
    else
      yield
    end
  end
  helper_method :with_error_proc
end
