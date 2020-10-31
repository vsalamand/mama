import Rails from 'rails-ujs'
import 'bootstrap';

$(document).on("turbolinks:load", function(event) {
  setStoreSectionHeaders();
})

$(document).on("DOMSubtreeModified", "#recipeItems", function(event) {
  setStoreSectionHeaders();
})

$(document).on("DOMSubtreeModified", "#recipeItems", function(event) {
  setStoreSectionHeaders();
})

// // close recipe modal when user wants to add recipe to a list
// $(document).on('click', '.addToListBtn',function() {
//   $('.showRecipeModal').modal('hide');
//   const recipeId = this.getAttribute('data');
//   const modal = "#addToListModal" + recipeId
//   $(modal).modal('show');
// });
//  Add recipe items to list
$(document).on("click" , "#addRecipeToListBtn", function(event) {

   // disable button
  $(this).prop("disabled", true);
  // add spinner to button
  $(this).html(
    `<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>`
  );

  // get items in list
  const recipeId = this.getAttribute('recipe-data');
  const listId = this.getAttribute('list-data');

  const selectedItems = document.querySelectorAll(".selectedItem");
  var items = [];
  $(selectedItems).map(function() {
                   items.push($(this).text().trim());

                });

  addRecipeToList(items, recipeId, listId);

});

function addRecipeToList(items, recipeId, listId) {
  // query suggested items
  $.ajax({
    url: "/recipes/" + recipeId + "/add_to_list",
    cache: false,
    dataType: 'script',
    data: {
        l: listId,
        i: items
        },
    success: function(){
    }
  });
}



$(document).on("click" , ".selectAllRecipeItemsBtn", function(event) {

  const recipeId = this.getAttribute('data');

  $.ajax({
    url: "/recipes/" + recipeId + "/select_all",
    cache: false,
    success: function(){
    }
  });

});



//  Edit list item
$(document).on("click", ".editRecipeListItemsModalbtn", function(event) {
  var recipeId = this.getAttribute('data');

  $.ajax({
    url: "/recipes/" + recipeId + "/edit_modal",
    cache: false,
    dataType: 'script',
    success: function(){
    }
  });

});


// show / hide section headers
function setStoreSectionHeaders() {
  if(document.getElementById("recipeItems")) {
    var headers = document.querySelectorAll('.listHeader');
    $(headers).map(function() {
     var count = $(this).find('li').length;
      if(count === 0){
         this.style.display = "none";
      } else {
         this.style.display = "block";
      }
    })
  }
}


//  update servings quanitites
$(document).on("click", "#updateServingsBtn", function(event) {
  var recipeId = this.getAttribute('data');
  var number = document.getElementById('servingsNum').value;

  $('#servingsModal').modal('hide');
  // $(document.body).removeClass('modal-open');
  $('.modal-backdrop').remove();

  $.ajax({
    url: "/recipes/" + recipeId + "/update_servings",
    cache: false,
    dataType: 'script',
    data: {
      s: number
    },
    success: function(){
    }
  });

});



// show recipes in list
$(document).on("click", ".fetchRecipes", function(event) {
  var listId = document.querySelector("#todo_list").getAttribute('data');
  $('#contentModal').modal('show')
  $('#contentShow').html(
    `<span class="spinner-border spinner-border-lg m-5" role="status" aria-hidden="true"></span>`
  );
  fetchRecipes(listId);
})

function fetchRecipes(listId) {
  $.ajax({
    url: "/recipes/fetch_recipes",
    cache: false,
    dataType: 'script',
    data: {
        l: listId,
        source: "meals"
        },
    success: function(){
    }
  });
}

// show recipe
$(document).on("click", ".loadRecipe", function(event) {
  var listId = document.querySelector("#todo_list").getAttribute('data');
  var recipeId = this.getAttribute('data');
  $('#contentModal').modal('show')
  $('#contentShow').html(
    `<span class="spinner-border spinner-border-lg m-5" role="status" aria-hidden="true"></span>`
  );
  showRecipe(recipeId, listId);
})

function showRecipe(recipeId, listId) {
  $.ajax({
    url: "/recipes/" + recipeId,
    cache: false,
    dataType: 'script',
    data: {
        l: listId
        },
    success: function(){
    }
  });
}


// Show category modal
$(document).on("turbolinks:load", function(event) {
  if(document.getElementById("todo_list")) {
    var searchParams = new URLSearchParams(window.location.search)

    if (searchParams.get('type') === "meals") {
      var listId = document.querySelector("#todo_list").getAttribute('data');
      $('#contentModal').modal('show')
      $('#contentShow').html(
        `<span class="spinner-border spinner-border-lg m-5" role="status" aria-hidden="true"></span>`
      );

      fetchRecipes(listId);

    }
  }
})
