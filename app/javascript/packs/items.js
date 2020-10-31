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



// show / hide item
$(document).on("click", ".fetchItem", function(event) {
  var itemId = this.getAttribute('data');
  $('#contentModal').modal('show')
  $('#contentShow').html(
    `<span class="spinner-border spinner-border-lg m-5" role="status" aria-hidden="true"></span>`
  );
  fetchCategory(itemId);
})

function fetchCategory(itemId) {
  $.ajax({
    url: "/items/" + itemId,
    cache: false,
    dataType: 'script',
    success: function(){
    }
  });
}


// Show item modal
$(document).on("turbolinks:load", function(event) {
  if(document.getElementById("todo_list")) {
    var searchParams = new URLSearchParams(window.location.search)

    if (searchParams.get('type') === "item") {
      var itemId = searchParams.get('content');
      $('#contentModal').modal('show')
      $('#contentShow').html(
        `<span class="spinner-border spinner-border-lg m-5" role="status" aria-hidden="true"></span>`
      );

      fetchCategory(itemId);

    }
  }
})
