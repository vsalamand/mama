import Rails from 'rails-ujs'

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
