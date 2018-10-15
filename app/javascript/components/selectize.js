import $ from 'jquery';
import 'selectize';

$(function() {
  $('.select').selectize({
    maxItems: 3,
    plugins: ['remove_button']
  });
});

// Requiring CSS! Path is relative to ./node_modules
import 'selectize/dist/css/selectize.default.css';
