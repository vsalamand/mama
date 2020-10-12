import Rails from 'rails-ujs'
import 'bootstrap';


$(document).on("click" , ".unselectedCategory", function(event) {
  const id = this.getAttribute('data');

  $.ajax({
    url: "/categories/" + id + "/select",
    cache: false,
    success: function(){
    }
  });
})


$(document).on("click" , ".selectedCategory", function(event) {
  const id = this.getAttribute('data');

  $.ajax({
    url: "/categories/" + id + "/unselect",
    cache: false,
    success: function(){
    }
  });
})

