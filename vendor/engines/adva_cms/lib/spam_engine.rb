module SpamEngine
  mattr_accessor :adapters
  @@adapters = []

  class << self
    def adapter(options)
      name = options[:engine] || 'None'
      options = (options[name] || {}).merge :approve => options[:approve_comments]
      "SpamEngine::#{name}".constantize.new options
    end

    def register(klass)
      @@adapters << klass.name
    end
    
    def names
      adapters.map &:demodulize
    end
  end
end