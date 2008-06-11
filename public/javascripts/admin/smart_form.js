Abstract.SmartEventObserver = Class.create(Abstract.EventObserver, {
  onElementEvent: function(event) {
    var value = this.getValue();
    if (this.lastValue != value) {
      this.callback(Event.element(event), value, event);
      this.lastValue = value;
    }
  }
});

var SmartForm = {};
SmartForm.EventObserver = Class.create(Abstract.EventObserver, {
  onElementEvent: function(event) {
    var value = this.getValue();
    if (this.lastValue != value) {
      this.callback(Event.element(event), value, event);
      this.lastValue = value;
    }
  },
  getValue: function() {
    return Form.serialize(this.element);
  }
});