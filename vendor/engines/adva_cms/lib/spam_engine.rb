module SpamEngine
  class << self
    def adapter(site, options = {})
      name = options[:engine] || 'None'
      "SpamEngine::#{name}".constantize.new(site, options[name])
    end
  end
end