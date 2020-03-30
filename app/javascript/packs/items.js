import Rails from 'rails-ujs'
import 'bootstrap';


$(document).on("click" , ".unselectedItem", function(event) {
  const itemId = this.getAttribute('data');

  $.ajax({
    url: "/items/" + itemId + "/select",
    cache: false,
    success: function(){
    }
  });
})


$(document).on("click" , ".selectedItem", function(event) {
  const itemId = this.getAttribute('data');

  $.ajax({
    url: "/items/" + itemId + "/unselect",
    cache: false,
    success: function(){
    }
  });
})
