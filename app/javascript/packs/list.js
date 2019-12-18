import Rails from 'rails-ujs'
import 'bootstrap';


require("jquery-ui/ui/widget")
require("jquery-ui/ui/widgets/sortable")


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
  $('#newListItem').focus()
})

// close modal when list item is submitted
$('#addListItemModal').submit(function() {
  $('#addListItemModal').modal('hide');
});
