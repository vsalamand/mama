import Rails from 'rails-ujs'
import 'bootstrap';


require("jquery-ui/ui/widget")
require("jquery-ui/ui/widgets/sortable")

// drag and drop list items to sort them out
document.addEventListener("turbolinks:load", function() {
  $("#uncomplete_list_items").sortable({
    update: function(e, ui) {
      Rails.ajax({
        url: $(this).data("url"),
        type: "PATCH",
        data: $(this).sortable('serialize'),
      });
    }
  });
});


// open modal when click on button
$('#addListModalBtn').on('click', function() {
  $('#addListItemModal').modal('show');
})

// on modal show, focus on input field
$('#addListItemModal').on('shown.bs.modal', function (e) {
  $('#newListItem').focus();
})

// close modal when list item is submitted
$('#addListItemModal').submit(function() {
  $('#addListItemModal').modal('hide');
});



// when click on food reco, add in input field as value
//$('#addListItemModal').on('shown.bs.modal', function (e) {
const form = document.getElementById('new_list_item');
const id = document.querySelector("#todo_list").getAttribute('data');

document.addEventListener("turbolinks:load", function (e) {
  // select word that is clicked
  // $('.recommendations').on('click', function(event) {
  $(document).on("click" , ".recommendations", function(event) {
    event.preventDefault();
    const item = event.target.innerText;
    const inputField = document.getElementById('newListItem');
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
    // // activate the submit button and deactivate suggestions
    // success(inputField, submitButton, suggestedItems);
    // // put focus on input field
    // $('#newListItem').focus();
  })
})

// When list item input field is empty, then disable submit button and show item suggestion lists
//$('#addListItemModal').on('shown.bs.modal', function (e) {
document.addEventListener("turbolinks:load", function (e) {
  const submitButton = document.getElementById('addListItemBtn');
  const inputField = document.getElementById('newListItem');
  const suggestedItems = document.querySelectorAll('#itemsRecommendations li');
  // disable button by default
  submitButton.disabled = true;
  // change state based on keyup event
  inputField.addEventListener("keyup", (event) => {
    success(inputField, submitButton, suggestedItems);
  });
})

function success(inputField, submitButton, suggestedItems) {
   if(inputField.value==="") {
            submitButton.disabled = true;
            enableElements(suggestedItems);
        } else {
            submitButton.disabled = false;
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

// $("body").on('DOMSubtreeModified', "#uncomplete_list_items", function() {
document.addEventListener("turbolinks:load", function (e) {
  loadSuggestions();
})

$("#uncomplete_list_items").on('DOMSubtreeModified', function() {
  loadSuggestions();
})

function loadSuggestions() {
  // `show spinner while calling data`
  $(itemsRecommendations).html(
    "<i class=\"fas fa-circle-notch fa-spin text-primary\"></i>"
  );
  $.ajax({
      url: "/lists/" + id +"/fetch_suggested_items",
      cache: false,
      success: function(){
      }
  });
}


