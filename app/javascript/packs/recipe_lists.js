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
