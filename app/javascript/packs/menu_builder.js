import Rails from 'rails-ujs'
import 'bootstrap';


const modalSpinner = document.getElementById('modalSpinner')

// show recipes suggestions in modal
$(document).on("click" , "#findRecipes", function(event) {
  loadRecipeSuggestions();
});

function loadRecipeSuggestions() {
  // query suggested items
  $.ajax({
    url: "/recipes/fetch_suggested_recipes",
    cache: false,
    success: function(){
    }
  });
}



//  Show recipe in modal
$(document).on("click" , ".recipeIndex", function(event) {
  const recipeId = this.getAttribute('data');
  loadRecipeCard(recipeId);
});

function loadRecipeCard(recipeId) {
  // query suggested items
  $.ajax({
    url: "/recipes/" + recipeId + "/fetch_recipe_card",
    cache: false,
    success: function(){
    }
  });
}


// show recipes suggestions in modal after user hit back button in recipe card view
$(document).on("click" , "#recipeBackBtn", function(event) {
  loadRecipeSuggestions();
});


// close modal when user hits Close btn
$(document).on('click', '#closeMenuBuilderBtn',function() {
  $('#menuBuilderModal').modal('hide');
  $(document.body).removeClass('modal-open');
  $('.modal-backdrop').remove();
});


//  Show recipe menu in modal
$(document).on("click" , "#showMenuBtn", function(event) {
  loadRecipeMenu();
});

function loadRecipeMenu(recipeId) {
  // query suggested items
  $.ajax({
    url: "/recipes/fetch_menu",
    cache: false,
    success: function(){
    }
  });
}



//  Add recipe to menu in modal
$(document).on("click" , "#addToMenuBtn", function(event) {
  const recipeId = document.getElementById("recipeCardId").getAttribute('data');
  addToMenu(recipeId);
});

function addToMenu(recipeId) {
  // query suggested items
  $.ajax({
    url: "/recipes/" + recipeId + "/add_to_menu",
    cache: false,
    success: function(){
    }
  });
}

//  Remove recipe from menu in modal
$(document).on("click" , "#removeFromMenuBtn", function(event) {
  const recipeListId = document.getElementById("recipeListId").getAttribute('data');
  const recipeListItemId = document.getElementById("recipeListItemCardId").getAttribute('data');
  removeFromMenu(recipeListItemId);
  loadRecipeMenu();
});

function removeFromMenu(recipeListItemId) {
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
$(document).on("click" , "#validateMenuBtn", function(event) {
  const listId = document.getElementById("todo_list");
  if(listId) {
    addMenuItemsToList(listId.getAttribute('data'));
  } else {
    addMenuItemsToList();
  }
});

function addMenuItemsToList(listId) {
  // query suggested items
  $.ajax({
    url: "/recipes/add_menu_to_list",
    cache: false,
    data: {
        list_id: listId
        },
    success: function(){
    }
  });
}
