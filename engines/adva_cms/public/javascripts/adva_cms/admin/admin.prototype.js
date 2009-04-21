var Comments = {
  filter: function() {
    location.href = "?filter=" + $F(this).toLowerCase();
  }
}

var SiteSelect = Class.create();
SiteSelect.change = function(event) {
  location.href = event.element().getValue();
}

var SiteSpamOptions = Class.create();
SiteSpamOptions.change = function(event) {
  var engine = event.element().value
  $$('.site_spam_settings').each(function(element){
    element.removeClassName('active');
  })
  $('site_spam_settings_' + engine.toLowerCase()).addClassName('active');
}

Event.addBehavior({
  '#site_select': function() { Event.observe(this, 'change', SiteSelect.change.bind(this)); },
  // '.site_spam_options_engine': function() { Event.observe(this, 'change', SiteSpamOptions.change.bind(this)); },
  '#comments_filter': function() { Event.observe(this, 'change', Comments.filter.bind(this)); }
}) 

// function log(line) {
//   $('log').update($('log').innerHTML + "<p>" + line + "</p>")
// }

