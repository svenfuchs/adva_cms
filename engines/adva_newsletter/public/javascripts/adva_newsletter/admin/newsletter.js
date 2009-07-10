AdvaExpandSave = $.klass({
  initialize: function(target) {
    this.target = $(target);
  },
  onclick: function(event) {
    this.element.hide();
    this.target.show();
		event.preventDefault();
  }
});

AdvaExpandBodyPlain = $.klass({
  initialize: function(target, autofill_src) {
    this.target = $(target);
    this.target_label = $("label[for='" + this.target.attr("id") + "']");
    this.autofill_src = $(autofill_src);
  },
  onclick: function(event) {
    this.toggle_controls();
    this.toggle_target();

    event.preventDefault();
  },
  toggle_controls: function() {
    this.element.siblings().show();
    this.element.hide();
  },
  toggle_target: function() {
    this.autofill();
    this.target_label.toggle();
    if (this.target.is(":hidden")) {
      this.target.show();
      this.target.attr("disabled", false);
    } else {
      this.target.hide();
      this.target.attr("disabled", true);
    }
  },
  autofill: function() {
    if (this.target.is(":hidden") && (this.target.val().length === 0)) {
      this.target.val(this.autofill_value());
    }
  },
  autofill_value: function() {
    alert(this.fckeditor_present());
    var text = "";
    if (this.fckeditor_present()) {
      text = $(this.fckeditor_instance().GetData()).text();
      alert(text);
    } else {
      text = this.autofill_src.val();
      alert(text);
    }
    return text
  },
  fckeditor_present: function() {
    if (typeof FCKeditorAPI != "undefined") {
      if (typeof this.fckeditor_instance() != "undefined") {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  },
  fckeditor_instance: function() {
    var editor_instance = FCKeditorAPI.GetInstance(this.autofill_src.attr("id"));
    return editor_instance;
  }
});

jQuery(function($) {
  $("#send_later").attach(AdvaExpandSave, "#send_later_expanded");
  $(".issue_body_plain_controls").attach(AdvaExpandBodyPlain, "#issue_body_plain", "#issue_body");
});
