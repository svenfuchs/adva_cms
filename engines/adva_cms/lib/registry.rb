class Registry < Hash
  class << self
    def instance
      @@instance ||= new
    end
    
    def get(*args)
      instance.set(*args)
    end

    def set(*args)
      instance.set(*args)
    end
    
    def clear
      instance.clear
    end
  end

  def set(*args)
    value = args.pop
    key = args.shift
    target(args)[key] = value
  end

  def get(*keys)
    key = keys.pop
    target(args)[key]
  end
  
  protected
  
    def target(keys)
      target = self
      while key = args.shift
        target[key] = {} unless target[key]
        target = target[key]
      end
      target
    end
end
