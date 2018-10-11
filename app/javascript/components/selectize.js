import $ from 'jquery';
import 'selectize';

$('.selectize').selectize({
    maxItems: 3
});

// Requiring CSS! Path is relative to ./node_modules
import 'selectize/dist/css/selectize.bootstrap3.css';
