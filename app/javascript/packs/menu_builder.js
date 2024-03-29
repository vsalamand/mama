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



// //  Show recipe in modal
// $(document).on("click" , ".recipeIndex", function(event) {
//   const recipeId = this.getAttribute('data');
//   loadRecipeCard(recipeId);
// });

//  Show recipe in modal with click referrer in modal
$(document).on("click" , ".recipeIndex", function(event) {
  let context = document.getElementById("menuBuilderContent").getAttribute('context');
  if(context == 'search') {
    let context = document.getElementById("menuBuilderContent").getAttribute('data');
    const recipeId = this.getAttribute('data');
    loadRecipeCard(recipeId, context);
  } else {
    let context = "recommended";
    const recipeId = this.getAttribute('data');
    loadRecipeCard(recipeId, context);
  }
});

function loadRecipeCard(recipeId, context) {
  // query suggested items
  $.ajax({
    url: "/recipes/" + recipeId + "/fetch_recipe_card",
    cache: false,
    data: {
        referrer: context
        },
    success: function(){
    }
  });
}



// show recipes suggestions in modal after user hit back button in recipe card view
$(document).on("click" , "#recipeBackBtn", function(event) {
  if (document.getElementById('menu')) {
    loadRecipeSuggestions();
  } else {
    const context = document.getElementById('recipeCardId').getAttribute('context');
    if(context == "recommended") {
      loadRecipeSuggestions();
    } else {
      loadRecipeSearch(context);
    }
  }
});


// close modal when user hits Close btn
$(document).on('click', '#closeMenuBuilderBtn', function(event) {
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


//  Load search recipe view in modal
$(document).on("click" , "#searchRecipesTab", function(event) {
  loadRecipeSearch();
});
// load suggested recipes in modal
$(document).on("click" , "#suggestedRecipesTab", function(event) {
  loadRecipeSuggestions();
});


function loadRecipeSearch(context) {
  // query suggested items
  $.ajax({
    url: "/recipes/search",
    dataType: 'script',
    cache: false,
    data: {
        query: context
        },
    success: function(){
    }
  });
}
