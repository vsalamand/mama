import Rails from 'rails-ujs'
import 'bootstrap';

//  Add recipe to menu
$(document).on("click" , "#addToMenuBtn", function(event) {

  const recipeId = this.getAttribute('data');
  const recipeListId = this.getAttribute('data-destination');
  addToMenu(recipeId, recipeListId);
});

function addToMenu(recipeId, recipeListId) {
  // query suggested items
  $.ajax({
    url: "/recipes/" + recipeId + "/add_to_menu",
    cache: false,
    data: {
        recipe_list_id: recipeListId
        },
    success: function(){
    }
  });
}


//  Remove recipe from menu
$(document).on("click" , "#removeFromMenuBtn", function(event) {
  const recipeListId = this.getAttribute('data-container');
  const recipeListItemId = this.getAttribute('data');
  removeFromMenu(recipeListId, recipeListItemId);
});

function removeFromMenu(recipeListId, recipeListItemId) {
  // query suggested items
  $.ajax({
    url: "/recipe_lists/" + recipeListId + "/recipe_list_items/" + recipeListItemId,
    cache: false,
    type: 'DELETE',
    success: function(){
    }
  });
}


//  Add menu items to list
$(document).on("click" , "#addMenuToListBtn", function(event) {

   // disable button
  $(this).prop("disabled", true);
  // add spinner to button
  $(this).html(
    `<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Chargement...`
  );

  // get items in list
  const items = []
  $(document.querySelectorAll(".menuItem")).map(function() {
                   items.push($(this).text());
                })

  const recipeListId = this.getAttribute('data');

  addToList(items, recipeListId);
});

function addToList(items, recipeListId) {
  // query suggested items
  $.ajax({
    url: "/recipe_lists/" + recipeListId + "/add_to_list",
    cache: false,
    data: {
        items: items
        },
    success: function(){
    }
  });
}



//  Remove item from menu list
$(document).on("click" , ".removeItemBtn", function(event) {
  const itemId = "#item" + this.getAttribute('data');
  var item = document.querySelector(itemId);
  item.remove();
});



//  Load more recipes in explore
$(document).on("click" , "#loadMoreRecipes", function(event) {
  const recipeListId = this.getAttribute('data');

  $.ajax({
    url: "/recipe_lists/" + recipeListId + "/fetch_recipes",
    cache: false,
    success: function(){
    }
  });
});
