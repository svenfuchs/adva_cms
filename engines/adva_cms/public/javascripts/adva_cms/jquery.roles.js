authorize_elements = function(roles) {
  if($.inArray('superuser', roles) > -1) {
    var elements = $('.visible_for');
  } else {
    var elements = [];
    $.each(roles, function() {
      $.each($('.' + this.toString()), function() {
        elements.push(this);
      });
    });
  }

  $.each(elements, function() {
    element = $(this);
    if(element) {
      element.removeClass('visible_for');
    }
  })
}

$(document).ready(function() {
  authorize_elements(['anonymous']);
});
