/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import 'bootstrap';
import '../components/selectize';
import '../components/selectize1';

// import Rails from 'rails-ujs';
// import Turbolinks from 'turbolinks';


// Rails.start();
// Turbolinks.start();

// tryuing to close modal after submit to new tab...
// $('.modal').on('hidden.bs.modal', function () {
//   location.reload();
// });

import { hideViewMoreBtn } from '../components/view_more';
hideViewMoreBtn();
