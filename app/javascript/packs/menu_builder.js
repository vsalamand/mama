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




