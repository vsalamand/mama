import Rails from 'rails-ujs'
import 'bootstrap';


require("jquery-ui/ui/widget")
require("jquery-ui/ui/widgets/sortable")

// sort();
// fetchSuggestedItems();
// loadSuggestions();

$(document).on("turbolinks:load", function(event) {
  // loadSuggestions();
  // getPriceBtn();
  // getListPlaceholder();
  setStoreSectionHeaders();
  setScore();
  // openSuggestedItemsModal();
  // disable Add List item button by default
  var submitButton = document.getElementById('addListItemBtn');
  $(submitButton).prop('disabled', true);
  // getCartsPrice();
})

$(document).on("DOMSubtreeModified", "#uncomplete_list_items", function(event) {
  // loadSuggestions();
  // getPriceBtn();
  setStoreSectionHeaders();
  setScore();
  // getListPlaceholder();
  // getCartsPrice();
})

$(document).on("DOMSubtreeModified", "#complete_list_items", function(event) {
  // getListPlaceholder();
  setStoreSectionHeaders();
  setScore();
})

// function sort() {
//   $("#uncomplete_list_items").sortable({
//     update: function(e, ui) {
//       Rails.ajax({
//         url: $(this).data("url"),
//         type: "PATCH",
//         data: $(this).sortable('serialize'),
//       });
//     }
//   });
// }


// // open modal when click on button
// $(document).on('click', '#loadStoreCartsBtn', function() {
//   $('#loadStoreCartModal').modal('show');
// })

// on modal show, focus on input field
$('#selectListModal').on('hide.bs.modal', function (e) {
  $('.modal').modal('hide');
  $(document).removeClass('modal-open');
  $('.modal-backdrop').remove();
})

// // close modal when list item is submitted
// $('#addListItemModal').submit(function() {
//   $('#addListItemModal').modal('hide');
// });



// when click on food reco, add in input field as value
//$('#addListItemModal').on('shown.bs.modal', function (e) {
const form = document.getElementById('new_item');
// const id = document.querySelector("#todo_list").getAttribute('data');

function fetchSuggestedItems() {
  // select word that is clicked
  // $('.recommendations').on('click', function(event) {
  $(document).on("click" , ".recommendations", function(event) {
    const item = event.target.innerText;
    const inputField = document.getElementById('newListItem');
    const id = document.querySelector("#todo_list").getAttribute('data');

    $.ajax({
      url: "/lists/" + id +"/list_items",
      cache: false,
      type: "POST",
      dataType: 'script',
      data: {
        list_item: {
          name: item}
        },
      success: function(data){
      }
    });

    // close modal is opened
    $('.modal').modal('hide');
    $(document.body).removeClass('modal-open');
    $('.modal-backdrop').remove();
  })
}

$(document).on("submit", "#new_item", function(event) {
  var addForm = document.getElementById('new_item');
  // $(addForm).html(
  //   `<div class="my-2">
  //     <div class="search-form-control border border-primary m-0 py-3 rounded bg-white">
  //     <i id="spinner" class="fas fa-circle-notch fa-spin text-primary mx-2"></i>
  //     </div>
  //   </div>
  //   `
  // );
  hideListItemForm();
})


$(document).on("keyup", "#newListItem", function(event) {
  var inputField = document.getElementById('newListItem');
  setInputForm(inputField);
})

// When list item input field is empty, ||| not used any more => then disable submit button and show item suggestion lists
function setInputForm(inputField) {
  var submitButton = document.getElementById('addListItemBtn');
  // change state based on keyup event
  success(inputField, submitButton);
}

function success(inputField, submitButton) {
   if(inputField.value==="") {
            $(submitButton).prop('disabled', true);
            // enableElements(suggestedItems);
        } else {
            $(submitButton).prop('disabled', false);
            // disableElements(suggestedItems);
        }
    }

function disableElements(list) {
  list.forEach((element) => {
    $(element).addClass("disabled");
  });
}

function enableElements(list) {
  list.forEach((element) => {
    $(element).removeClass("disabled");
  });
}

// show / hide top and bottom menu while focus on create form
$(document).on("focus", "#toggleListItemform", function(event) {
  showListItemForm();
})
$(document).on("click", "#hideNewlistItemForm", function(event) {
  hideListItemForm();
})

function showListItemForm() {
  var newListItemForm = document.getElementById('newlistItemForm');
  newListItemForm.style.display = "block";
  $('#newListItem').focus();
  var listShow = document.getElementById('listShow');
  listShow.style.display = "none";
  hideBottomMenu();
}

function hideListItemForm() {
  var newListItemForm = document.getElementById('newlistItemForm');
  newListItemForm.style.display = "none";
  var listShow = document.getElementById('listShow');
  listShow.style.display = "block";
  showBottomMenu();
}

function hideBottomMenu() {
  var bottomMenu = document.getElementById('menuBarBottom');
  bottomMenu.style.display = "none";
}

function showBottomMenu() {
  var bottomMenu = document.getElementById('menuBarBottom');
  bottomMenu.style.display = "block";
}


// On form submit, fetch updated suggested items inside the form
const itemsRecommendations = document.getElementById('itemsRecommendations');
// const spinner = document.getElementById('spinner');



// function loadSuggestions() {
//   if(document.querySelector("#todo_list")){
//     const id = document.querySelector("#todo_list").getAttribute('data');
//     // Show spinner while doing ajax call
//     $(spinner).show();
//     // query suggested items
//     $.ajax({
//       url: "/lists/" + id +"/fetch_suggested_items",
//       cache: false,
//       success: function(){
//       }
//     });
//   }
// }

// function getPriceBtn() {
//   var count = $("#uncomplete_list_items li").length;
//   const btn = document.getElementById('loadStoreCartsBtn')

//   if(count > 0){
//     $(btn).show();
//   } else {
//     $(btn).hide();
//   }
// }


// function getListPlaceholder() {
//   if(document.getElementById("todo_list")) {
//     var totalCount = $("#uncomplete_list_items li").length + $("#complete_list_items li").length;
//     const placeholder = document.getElementById('listPlaceholder');
//     const sortListBtn = document.getElementById('sortList');
//     const openRecoBtn = document.getElementById('openSelect');
//     const listItemForm = document.getElementById('listItemForm');

//     if(totalCount == 0){
//       $(placeholder).show();
//       $(sortListBtn).hide();
//       $(openRecoBtn).hide();
//       $(listItemForm).hide();
//       // loadSuggestedItems();
//     } else {
//       $(placeholder).hide();
//       $(sortListBtn).show();
//       $(openRecoBtn).show();
//       $(listItemForm).show();
//     }
//   }
// }


// function openSuggestedItemsModal() {
//   var totalCount = $("#uncomplete_list_items li").length + $("#complete_list_items li").length;
//   const selectSuggestedItemsModal = document.getElementById('selectItemsModal');

//   if(totalCount == 0){
//     $(selectSuggestedItemsModal).modal('show');
//   }
// }


// // on Get Price modal show, get store prices
// $(document).on('click', '#selectStoreBtn',function() {
//   getCartsPrice();
// })


// function getCartsPrice() {
//   if(document.querySelector("#todo_list")){
//     const id = document.querySelector("#todo_list").getAttribute('data');
//     var cartsPrice = document.getElementById('listCartPrice');
//     var modalSpinner = document.querySelectorAll('#modalSpinner');

//     $(cartsPrice).hide();
//     $(modalSpinner).show();

//     $.ajax({
//       url: "/lists/" + id +"/fetch_price",
//       cache: false,
//       success: function(){
//         $(cartsPrice).show();
//         $(modalSpinner).hide();
//       }
//     });

//   }
// }



// close select store modal when user selects share list
$(document).on('click', '#shareList',function() {
  $('#selectStoreModal').modal('hide');
  $(document.body).removeClass('modal-open');
  $('.modal-backdrop').remove();
  $('#shareModal').modal('show');
});



//  Load suggested items in modal
// $(document).on("click", "#openSuggestedItemsBtn", function(event) {
//   loadSuggestedItems();
// });

// function loadSuggestedItems() {
//   const listId = document.getElementById('getSuggestedItems').getAttribute('data');

//   $.ajax({
//     url: "/lists/" + listId + "/get_suggested_items",
//     cache: false,
//     success: function(){
//     }
//   });
// }


//  Update list sorting
$(document).on("click", ".sortOptionBtn", function(event) {
  var option = this.getAttribute('data');
  sortList(option);
});

function sortList(option) {
  const id = document.querySelector("#todo_list").getAttribute('data');

  $.ajax({
    url: "/lists/" + id +"/sort",
    cache: false,
    data: {
      sort_option: option
      },
    success: function(data){
    }
  });
}


//  Remove recipe from list
$(document).on("click", "#removeRecipefromListBtn", function(event) {
  var recipeId = this.getAttribute('data');
  const id = document.querySelector("#todo_list").getAttribute('data');

  removeRecipe(recipeId, id);
});

function removeRecipe(recipeId, id) {
  $.ajax({
    url: "/lists/" + id + "/remove_recipe",
    cache: false,
    data: {
      recipe_id: recipeId
      },
    success: function(data){
    }
  });
}


//  Update email list button state
$(document).on("click", "#emailList", function(event) {
  var emailButton = document.getElementById('emailList');
  emailButton.value = "Envoyée !"
});


//  Update button state when editing list item
$(document).on("click", ".editListItemBtn", function(event) {
  // add spinner to button
  $(this).html(
    `<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Chargement...`
  );
});


//  Edit list item
$(document).on("click", ".editListItemModalbtn", function(event) {
  var listId = document.querySelector("#todo_list").getAttribute('data');
  var itemId = this.getAttribute('data');

  $.ajax({
    url: "/lists/" + listId + "/items/" + itemId + "/edit_modal",
    cache: false,
    dataType: 'script',
    success: function(){
    }
  });

});


// Select all items
$(document).on("click" , ".selectAllListItemsBtn", function(event) {

  const listId = this.getAttribute('data');

  $.ajax({
    url: "/lists/" + listId + "/select_all",
    cache: false,
    success: function(){
    }
  });


});


// show / hide store section header
function setStoreSectionHeaders() {
  if(document.getElementById("todo_list")) {
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


// Set list score
function setScore() {
  if(document.querySelector("#todo_list")){
    var listId = document.querySelector("#todo_list").getAttribute('data');

    $.ajax({
      url: "/lists/" + listId + "/get_score",
      cache: false,
      success: function(){
      }
    });
  }
}



// get rating progress detail view
$(document).on("click", "#showRatingProgress", function(event) {
  var listId = document.querySelector("#todo_list").getAttribute('data');

  $.ajax({
    url: "/lists/" + listId + "/get_rating_progress",
    cache: false,
    success: function(){
    }
  });
  var ratingElement = document.querySelector("#ratingProgress");
  ratingElement.style.display = "block";
})

// hide rating progress view
$(document).on("click", "#closeRatingProgress", function(event) {
  var ratingElement = document.querySelector("#ratingProgress");
  ratingElement.style.display = "none";
})



