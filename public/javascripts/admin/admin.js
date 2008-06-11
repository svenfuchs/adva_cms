var Comments = {
  filter: function() {
    location.href = "?filter=" + $F(this).toLowerCase();
  }
}

var SiteSelect = Class.create();
SiteSelect.change = function(event) {
  location.href = event.element().getValue();
}

Event.addBehavior({
  '#site-select':     function() { Event.observe(this, 'change', SiteSelect.change.bind(this)); },
  '#comments-filter': function() { Event.observe(this, 'change', Comments.filter.bind(this)); }
}) 

// function log(line) {
//   $('log').update($('log').innerHTML + "<p>" + line + "</p>")
// }

