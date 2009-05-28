// disable or enable fields when onclick event is triggered
FieldDisabler = $.klass({
  initialize: function(fields) {
    this.fields = $(fields.toString());
  },
  onclick: function() {
    if(this.element.attr("checked")) {
      this.fields.attr("disabled", false);
      $.event.trigger("on_field_enable");
    } else {
      this.fields.attr("disabled", true);
    };
  }
});

// pre-fill field with default value when custom on_field_enable event is triggered
FieldDefaultValuer = $.klass({
  initialize: function(selector) {
    this.selector = selector;
    $(this).bind("on_field_enable", function() {});
  },
  on_field_enable: function() {
    if (this.element.val() == "") {
      var default_value = $(this.selector).val();
      this.element.val(default_value);
    }
  },
});

jQuery(function($) {
  $("#issue_track").attach(FieldDisabler, ["#issue_tracking_campaign", "#issue_tracking_source"]);
  $("#issue_tracking_source").attach(FieldDefaultValuer, "#issue_title");
});
