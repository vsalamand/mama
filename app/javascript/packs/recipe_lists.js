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
      // update CTA
      getGoToMenuBtn();
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
      // update CTA
      getGoToMenuBtn();
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
  const recipeListId = this.getAttribute('data');
  const recipeListClass = ".recipeListItems" + recipeListId;
  const recipeListSelector = document.querySelector(recipeListClass);
  console.log(recipeListSelector)

  const selectedItems = recipeListSelector.querySelectorAll(`.selectedItem`);

  const items = []
  $(selectedItems).map(function() {
                   items.push($(this).text().trim());
                })


  addMenuToList(items, recipeListId);
});

function addMenuToList(items, recipeListId) {
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



$(document).on("turbolinks:load", function(event) {
  getGoToMenuBtn();
})

function getGoToMenuBtn() {
  if(document.getElementById('explore')){
    const recipeListId = document.getElementById('explore').getAttribute('data');
    const btn = document.getElementById('goToMenuBtn')
    $.ajax({
      type: "GET",
      contentType: "application/json",
      dataType: 'json',
      url: "/recipe_lists/" + recipeListId + "/get_size",
      cache: false,
      success: function(menu_size){
        if(menu_size > 0){
          $(btn).show();
        } else {
          $(btn).hide();
        }
      }
    });
  }
}
