// tooltip widget
function toggleTooltip(event, element) { 
  var __x = Event.pointerX(event);
  var __y = Event.pointerY(event);
  //alert(__x+","+__y);
  element.style.top = __y + 5;  
  element.style.left = __x - 40;
  element.toggle();
}