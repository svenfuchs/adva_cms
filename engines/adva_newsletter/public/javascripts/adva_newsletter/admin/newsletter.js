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

AdvaControlBodyPlain = $.klass({
  initialize: function(target, autofill_src) {
    this.target = $(target);
    this.target_label = $("label[for='" + this.target.attr("id") + "']");
    this.autofill_src = $(autofill_src);
  },
  onclick: function(event) {
    this.target.is(":hidden") ? this.show() : this.hide()
    event.preventDefault();
  },
  show: function() {
    this.autofill();
    this.toggle_controls();
    this.toggle_target();
  },
  hide: function() {
    if (confirm($("#adva_newsletter_issue_confirm_remove_body_plain").val())) {
      this.target.val("");
      this.toggle_controls();
      this.toggle_target();
    }
  },
  toggle_controls: function() {
    this.element.siblings().show();
    this.element.hide();
  },
  toggle_target: function() {
      this.target_label.toggle();
      this.target.toggle();
  },
  autofill: function() {
    if (this.target.is(":hidden") && (this.target.val().length === 0)) {
      this.target.val(this.autofill_value());
    }
  },
  autofill_value: function() {
    var text = "";
    text = (this.fckeditor_present()) ? $(this.fckeditor_instance().GetData()).text() : this.autofill_src.val()
    return text;
  },
  fckeditor_present: function() {
    if (typeof FCKeditorAPI != "undefined") {
      return (typeof(this.fckeditor_instance()) != "undefined")
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
  $(".issue_body_plain_controls").attach(AdvaControlBodyPlain, "#issue_body_plain", "#issue_body");
});
