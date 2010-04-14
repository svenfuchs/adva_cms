require 'rubygems'

require 'ruby2ruby'
begin
  require 'ruby_parser' # try to load RubyParser and use it if present
rescue LoadError => e
end
# this doesn't work somehow. Maybe something changed inside
# ParseTree or sexp_processor or so.
# (the require itself works, but ParseTree doesn't play nice)
# begin
#   require 'parse_tree'
# rescue LoadError => e
# end

require 'safemode/core_ext'
require 'safemode/blankslate'
require 'safemode/exceptions'
require 'safemode/jail'
require 'safemode/core_jails'
require 'safemode/parser'
require 'safemode/scope'
require 'safemode/rails_ext'

module Safemode
  class << self
    def jail(obj)
      find_jail_class(obj.class).new obj
    end

    def find_jail_class(klass)
      while klass != Object
        return klass.const_get('Jail') if klass.const_defined?('Jail')
        klass = klass.superclass
      end
      Jail
    end
  end

  Boxes = {}

  define_core_jail_classes

  class Box
    def initialize(code, filename, line)
      @code = jail(code)
      @filename = filename
      @line = line
    end

    def jail(code)
      code = Parser.jail(code)
    end

    def eval(delegate = nil, methods = [], assigns = {}, locals = {}, &block)
      scope = Scope.new(delegate, methods)
      binding = scope.bind(assigns, locals, &block)
      result = Kernel.eval(@code, binding, @filename, @line)
    end

    def output
      @scope.output
    end
  end
end
