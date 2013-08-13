/*
* handles form serialization into a JSON data structure
*/

$.fn.serializeObject = function() {
  var o = {};
  var a = this.serializeArray();

  $.each(a, function() {
      if (o[this.name]) {
    if (!o[this.name].push) {
        o[this.name] = [o[this.name]];
    }
    o[this.name].push(this.value || '');
      } else {
    o[this.name] = this.value || '';
      }
  });
  return o;
};

window.serializeForm = function(elements) {
  elements = _.map(elements, function(em) {
   if ($(em).attr('type') == 'checkbox') {
     if (!$(em).is(':checked')) {
       $(em).val("")
       return $(em).attr('checked','checked');
     }
     return em;
   } else {
     return em;
   }
  })
  return $(elements).serializeObject();
}

