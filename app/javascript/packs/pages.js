import Rails from 'rails-ujs'
import 'bootstrap';

// go to select products
$(document).on("click" , "#goToSelectProductsBtn", function(event) {
   // disable button
  $(this).prop("disabled", true);
  // add spinner to button
  $(this).html(
    `<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Chargement...`
  );

  var selectedRecipes = document.querySelectorAll("#selectedRecipes div");
  var items = this.getAttribute('data');
  var listId = this.getAttribute('list-data');

  var recipeIds = []
  $(selectedRecipes).map(function() {
                   recipeIds.push(this.getAttribute('id'));
                })

  var recipeIds = recipeIds.filter(Boolean)
  goToSelectProducts(items, recipeIds, listId);
})

function goToSelectProducts(items, recipeIds, listId) {
  $.ajax({
    url: "select_products",
    cache: false,
    data: {
       i: items,
       r: recipeIds,
       l: listId
      },
    success: function(data){
    }
  });
}


// go to select recipes
$(document).on("click" , "#goToSelectRecipesBtn", function(event) {
   // disable button
  $(this).prop("disabled", true);
  // add spinner to button
  $(this).html(
    `<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Chargement...`
  );

  var recipeIds = this.getAttribute('recipe-data');
  var listId = this.getAttribute('list-data');

  if(document.getElementById('essentials')){
    const selectedItems = document.querySelectorAll("#essentials .selectedItem");
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

  goToSelectRecipes(items, recipeIds, listId);
})

function goToSelectRecipes(items, recipeIds, listId) {
  $.ajax({
    url: "select_recipes",
    cache: false,
    data: {
       i: items,
       r: recipeIds,
       l: listId
      },
    success: function(data){
    }
  });
}


// go to list
$(document).on("click" , "#goToListBtn", function(event) {
   // disable button
  $(this).prop("disabled", true);
  // add spinner to button
  $(this).html(
    `<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Chargement...`
  );

  var selectedRecipes = document.querySelectorAll("#selectedRecipes div");
  var items = this.getAttribute('data');
  var listId = this.getAttribute('list-data');


  var recipeIds = []
  $(selectedRecipes).map(function() {
                   recipeIds.push(this.getAttribute('id'));
                })

  var recipeIds = recipeIds.filter(Boolean)

// This is the function at the bottom to create a new list !!!
  goToList(items, listId, recipeIds);
})

//  not used currently
function goToList(items, listId, recipeIds) {
  $.ajax({
    url: "get_list",
    cache: false,
    data: {
        r: recipeIds,
        i: items,
        l: listId
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



//  Add to list
$(document).on("click" , "#addToListBtn", function(event) {

   // disable button
  $(this).prop("disabled", true);
  // add spinner to button
  $(this).html(
    `<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Chargement...`
  );

  var selectedRecipes = document.querySelectorAll("#selectedRecipes div");
  var items = this.getAttribute('data');
  var listId = this.getAttribute('list-data');


  var recipeIds = []
  $(selectedRecipes).map(function() {
                   recipeIds.push(this.getAttribute('id'));
                })

  var recipeIds = recipeIds.filter(Boolean)
  // // get items in list
  // const listId = this.getAttribute('list-data');
  // const recipeIds = this.getAttribute('recipe-data');
  // const selectedItems = document.querySelectorAll(`.selectedItem`);
  // var items = []
  // $(selectedItems).map(function() {
  //                  items.push($(this).text().trim());
  //               })

  addToList(items, listId, recipeIds);
});

function addToList(items, listId, recipeIds) {
  // query suggested items
  $.ajax({
    url: "/add_to_list",
    cache: false,
    dataType: 'script',
    data: {
        l: listId,
        i: items,
        r: recipeIds
        },
    success: function(){
    }
  });
}
