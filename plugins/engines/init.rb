# Only call Engines.init once, in the after_initialize block so that Rails
# plugin reloading works when turned on
config.after_initialize do
  Engines.init if defined? :Engines
end

# reverted that change because it gets me into a stack level to deep error, see comment 
# on http://github.com/lazyatom/engines/commit/f7656144b71685c06cfc04dbf41825358646b466
# Engines.init if defined? :Engines