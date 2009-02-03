module NoPeepingToms
  def with_observers(*observer_syms)
    observer_names = [observer_syms].flatten
    observers = observer_names.map { |o| o.to_s.classify.constantize.instance }
    
    observers.each { |o| old_add_observer(o) }
    yield
    observers.each { |o| delete_observer(o) }
  end
end
