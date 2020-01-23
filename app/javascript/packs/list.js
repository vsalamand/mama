import Rails from 'rails-ujs'
import 'bootstrap';


require("jquery-ui/ui/widget")
require("jquery-ui/ui/widgets/sortable")

sort();
fetechSuggestedItems();
loadSuggestions();


function sort() {
  $("#uncomplete_list_items").sortable({
    update: function(e, ui) {
      Rails.ajax({
        url: $(this).data("url"),
        type: "PATCH",
        data: $(this).sortable('serialize'),
      });
    }
  });
}


// // open modal when click on button
// $('#addListModalBtn').on('click', function() {
//   $('#addListItemModal').modal('show');
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
const form = document.getElementById('new_list_item');
// const id = document.querySelector("#todo_list").getAttribute('data');

function fetechSuggestedItems() {
  // select word that is clicked
  // $('.recommendations').on('click', function(event) {
  $(document).on("click" , ".recommendations", function(event) {
    const item = event.target.innerText;
    const inputField = document.getElementById('newListItem');
    const id = document.querySelector("#todo_list").getAttribute('data');
    // const submitButton = document.getElementById('addListItemBtn');
    // const suggestedItems = document.querySelectorAll('#itemsRecommendations li');
    // // add the word to the input field
    // inputField.value = item;
    // // submit form
    // Rails.fire(form, 'submit');
    // create new list item
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

// When list item input field is empty, then disable submit button and show item suggestion lists
//$('#addListItemModal').on('shown.bs.modal', function (e) {
function setInputForm() {
  let submitButton = document.getElementById('addListItemBtn');
  let inputField = document.getElementById('newListItem');
  let suggestedItems = document.querySelectorAll('#itemsRecommendations li');
  // disable button by default
  $(submitButton).prop('disabled', true);
  // change state based on keyup event
  if(inputField){
    $(document).on("keyup" , inputField, function(event) {
      success(inputField, submitButton, suggestedItems);
    });
  }
}

function success(inputField, submitButton, suggestedItems) {
   if(inputField.value==="") {
            $(submitButton).prop('disabled', true);
            enableElements(suggestedItems);
        } else {
            $(submitButton).prop('disabled', false);
            disableElements(suggestedItems);
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



// On form submit, fetch updated suggested items inside the form
const itemsRecommendations = document.getElementById('itemsRecommendations');
const spinner = document.getElementById('spinner')


$(document).on("turbolinks:load", function(event) {
  loadSuggestions();
  setInputForm();
  getCartsPrice();
})

$(document).on("DOMSubtreeModified", "#uncomplete_list_items", function(event) {
  loadSuggestions();
  getCartsPrice();
})

function loadSuggestions() {
  if(document.querySelector("#todo_list")){
    const id = document.querySelector("#todo_list").getAttribute('data');
    // Show spinner while doing ajax call
    $(spinner).show();
    // query suggested items
    $.ajax({
      url: "/lists/" + id +"/fetch_suggested_items",
      cache: false,
      success: function(){
      }
    });
  }
}

function getCartsPrice() {
  if(document.querySelector("#todo_list")){
    const id = document.querySelector("#todo_list").getAttribute('data');

    $.ajax({
      url: "/lists/" + id +"/fetch_price",
      cache: false,
      success: function(){
      }
    });

  }
}

