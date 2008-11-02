module Rbac
  @@definition = nil
  @@initialized = false
  
  class << self
    def initialized?
      @@initialized
    end
    
    def initialize!
      unless initialized?
        module_eval &@@definition
        @@initialized = true
      end
    end
    
    def define(&definition)
      @@definition = definition
    end
    
    def role(*args)
      Rbac::Role.define *args
    end
    
    def permissions(permissions)
      Rbac::Context.permissions = permissions
    end
  end
end