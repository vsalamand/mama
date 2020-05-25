import Rails from 'rails-ujs'
import 'bootstrap';

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
    `<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Chargement...`
  );

  // get items in list
  const recipeId = this.getAttribute('data');
  const recipeClass = ".recipeItem" + recipeId;
  const recipeSelector = document.querySelector(recipeClass);

  const selectedItems = recipeSelector.querySelectorAll(`.selectedItem`);

  const items = []
  $(selectedItems).map(function() {
                   items.push($(this).text().trim());
                })

  addRecipeToList(items, recipeId);

});

function addRecipeToList(items, recipeId) {
  // query suggested items
  $.ajax({
    url: "/recipes/" + recipeId + "/add_to_list",
    cache: false,
    data: {
        items: items
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
