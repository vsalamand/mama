import Rails from 'rails-ujs'
import 'bootstrap';

// go to select products
$(document).on("click" , "#goToSelectProductsBtn", function(event) {
  var selectedRecipes = document.querySelectorAll("#selectedRecipes div");
  var items = this.getAttribute('data')

  var recipeIds = []
  $(selectedRecipes).map(function() {
                   recipeIds.push(this.getAttribute('id'));
                })

  var recipeIds = recipeIds.filter(Boolean)
  goToSelectProducts(items, recipeIds);
})

function goToSelectProducts(items, recipeIds) {
  $.ajax({
    url: "select_products",
    cache: false,
    data: {
       i: items,
       r: recipeIds
      },
    success: function(data){
    }
  });
}


// go to select recipes
$(document).on("click" , "#goToSelectRecipesBtn", function(event) {
  var recipeIds = this.getAttribute('recipe-data');

  if(document.getElementById('essentials')){
    const selectedItems = document.getElementById('essentials').querySelectorAll(".selectedItem");
    var items = []
    $(selectedItems).map(function() {
                     items.push($(this).text().trim());
                  })

  } else{
    const selectedItems = document.querySelectorAll(".selectedItem");
    var items = []
    $(selectedItems).map(function() {
                     items.push($(this).text().trim());
                  })
  }

  goToSelectRecipes(items, recipeIds);
})

function goToSelectRecipes(items, recipeIds) {
  $.ajax({
    url: "select_recipes",
    cache: false,
    data: {
       i: items,
       r: recipeIds
      },
    success: function(data){
    }
  });
}


// go to list
$(document).on("click" , "#goToListBtn", function(event) {

  var selectedRecipes = document.querySelectorAll("#selectedRecipes div");
  var items = this.getAttribute('data')

  var recipeIds = []
  $(selectedRecipes).map(function() {
                   recipeIds.push(this.getAttribute('id'));
                })

  var recipeIds = recipeIds.filter(Boolean)

  goToList(recipeIds, items);
})

function goToList(recipeIds, items) {
  $.ajax({
    url: "get_list",
    cache: false,
    data: {
        r: recipeIds,
        i: items
      },
    success: function(data){
    }
  });
}




//  Load explore recipes in modal
$(document).on("click", "#openExploreModalBtn", function(event) {
  fetchExploreRecipes();
});

function fetchExploreRecipes() {
  $.ajax({
    url: "explore_recipes",
    cache: false,
    success: function(){
    }
  });
}



//  Load browse category in modal
$(document).on("click", "#getCategoryBtn", function(event) {
  var categoryId = this.getAttribute('data');
  fetchBrowseCategory(categoryId);
});

function fetchBrowseCategory(categoryId) {
  $.ajax({
    url: "browse_category",
    cache: false,
    data: {
      category_id: categoryId
      },
    success: function(data){
    }
  });
}


//  Add recipe to selected list
$(document).on("click", "#selectRecipeBtn", function(event) {
  var recipeId = this.getAttribute('data');
  addRecipe(recipeId);
  // close modal is opened
  $('.modal').modal('hide');
  $(document.body).removeClass('modal-open');
  $('.modal-backdrop').remove();
});

function addRecipe(recipeId) {
  $.ajax({
    url: "add_recipe",
    cache: false,
    data: {
      recipe_id: recipeId
      },
    success: function(data){
    }
  });
}


//  AdRemoved recipe to selected list
$(document).on("click", "#removeRecipeBtn", function(event) {
  var recipeId = this.getAttribute('data');
  removeRecipe(recipeId);
});

function removeRecipe(recipeId) {
  $.ajax({
    url: "remove_recipe",
    cache: false,
    data: {
      recipe_id: recipeId
      },
    success: function(data){
    }
  });
}


//  show browse category dropdown options
// make bootstrap dropdowns work with turbolinks
function toggleDropdown(element) {
  var dropdown = new Dropdown(element);
  dropdown.toggle();
}

$(document).on("click", "#categoryMenuButton", function(event) {
  var options = document.getElementById('categoryMenuButton');
  $(options).dropdown('show')

  var dropdown_buttons = document.querySelectorAll('[data-toggle="dropdown"]');

  dropdown_buttons.forEach(function(element) {
    element.addEventListener('click', function(event) {
      event.preventDefault();

      toggleDropdown(this);
    });
  });
});
