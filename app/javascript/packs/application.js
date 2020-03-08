/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// import Rails from 'jquery_ujs'
import 'bootstrap';

import '../components/selectize';
import '../components/selectize1';

import 'packs/list';
import 'packs/cart';
import 'packs/store_cart';
import 'packs/recipe_lists';
import 'packs/recipes';



//// Handle Turbolinks side-issues
// clear the cache often
$(document).on('ajax:before', '[data-remote]', () => {
  Turbolinks.clearCache();
});

// manage bootstrap modals
document.addEventListener('turbolinks:before-cache', () => {
  // Manually tear down bootstrap modals before caching. If turbolinks
  // caches the modal then tries to restore it, it breaks bootstrap's JS.
  // We can't just use bootstrap's `modal('close')` method because it is async.
  // Turbolinks will cache the page before it finishes running.
  if (document.body.classList.contains('modal-open')) {
    $('.modal')
      .hide();
    $('.modal-backdrop').remove();
    $(document.body).removeClass('modal-open');
  }
});


// make bootstrap dropdowns work with turbolinks
function toggleDropdown(element) {
  var dropdown = new Dropdown(element);
  dropdown.toggle();
}

document.addEventListener('turbolinks:load', function() {
  var dropdown_buttons = document.querySelectorAll('[data-toggle="dropdown"]');

  dropdown_buttons.forEach(function(element) {
    element.addEventListener('click', function(event) {
      event.preventDefault();

      toggleDropdown(this);
    });
  });
});

// close  modal after click
$(document).on('click', '#startGroceriesModal',function() {
  $('.modal').modal('hide');
});

// // close all modal after click on cross
$(document).on('click', '.closeModal',function() {
  $('.modal').modal('hide');
  $(document.body).removeClass('modal-open');
  $('.modal-backdrop').remove();
});



