import Rails from 'rails-ujs'
import 'bootstrap';

$(document).on("turbolinks:load", function(event) {
  setScore();
})


// Set list score
function setScore() {
  if(document.querySelector("#score")){

    $.ajax({
      url: "/get_score",
      cache: false,
      success: function(){
      }
    });
  }
}

$(document).on("click" , "#getScoreBtn", function(event) {

   // disable button
  $(this).prop("disabled", true);
  // add spinner to button
  $(this).html(
    `<button class="btn btn-light border" type="button" disabled>
      <span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>
      <span class="sr-only">Chargement...</span>
    </button>
    `
  );

});

