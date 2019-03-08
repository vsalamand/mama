import $ from 'jquery';
import 'selectize';

$(function() {
 $('.select').selectize({
   plugins: ['remove_button'],
   closeAfterSelect: true,
 });
});

// // Requiring CSS! Path is relative to ./node_modules
import 'selectize/dist/css/selectize.bootstrap3.css';
