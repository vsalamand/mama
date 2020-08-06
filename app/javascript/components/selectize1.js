import $ from 'jquery';
import 'selectize';

$(document).on('turbolinks:load', function() {
 $('.selectone').selectize({
   plugins: ['remove_button'],
   closeAfterSelect: true,
   maxItems: 1,
 });
});



// // Requiring CSS! Path is relative to ./node_modules
import 'selectize/dist/css/selectize.bootstrap3.css';
