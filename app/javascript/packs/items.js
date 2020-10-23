import Rails from 'rails-ujs'
import 'bootstrap';


$(document).on("click" , ".unselectedItem", function(event) {
  const itemId = this.getAttribute('data');
  var servings_delta = this.getAttribute('servings-data');

  $.ajax({
    url: "/items/" + itemId + "/select",
    cache: false,
    data: {
      s: servings_delta
    },
    success: function(){
    }
  });
})


$(document).on("click" , ".selectedItem", function(event) {
  const itemId = this.getAttribute('data');
  var servings_delta = this.getAttribute('servings-data');

  $.ajax({
    url: "/items/" + itemId + "/unselect",
    cache: false,
    data: {
      s: servings_delta
    },
    success: function(){
    }
  });
})


$(document).on("click" , "#addSuggestedItemsToListBtn", function(event) {

   // disable button
  $(this).prop("disabled", true);
  // add spinner to button
  $(this).html(
    `<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Chargement...`
  );

  const listId = this.getAttribute('data');
  const selectedItems = document.querySelectorAll(".selectedItem");

  const items = []
  $(selectedItems).map(function() {
                   items.push($(this).text().trim());
                })

  addToList(items, listId);
})

function addToList(items, listId) {
  // query suggested items
  $.ajax({
    url: "/lists/" + listId + "/add",
    cache: false,
    data: {
        items: items
        },
    success: function(){
    }
  });
}
