import Rails from 'rails-ujs'
import 'bootstrap';


// open Add product modal when click on button
$(document).on('click', '#addProducts', function() {
  $('#addProductsModal').modal('show');
})



// prevent click to open Update Product modal
$(document).on('click', ".deleteBtn", function(e){
    e.stopPropagation();
});

// open update product modal when click on button
$(document).on('click', '.cartItemShow', function() {
  const cartItemId = this.getAttribute('data');
  const updateModal = "#updateProductModal" + cartItemId
  $(updateModal).modal('show');
})

// close update product modal when list item is submitted
$(document).on('click', '.buyBtn',function() {
  $('.modal').modal('hide');
});

// hide order modal after click on option
$(document).on('click', '#shareCart', function() {
  $('#orderModal').modal('hide');
})



$(document).on("turbolinks:load", function(event) {
  getCartPrice();
})

function getCartPrice() {
  if(document.querySelector("#cartPrice")){
    const cartId = document.querySelector("#cartId").getAttribute('data');

    $.ajax({
      url: "/carts/" + cartId + "/fetch_price",
      cache: false,
      success: function(){
      }
    });

  }
}

$(document).on('click', '.sizeBtn',function() {
  setTimeout(getCartPrice,200);
});

$(document).on('click', '.deleteBtn',function() {
  setTimeout(getCartPrice,200);
});

$(document).on('click', '.buyBtn',function() {
  $('.modal').modal('hide');
  $(document.body).removeClass('modal-open');
  $('.modal-backdrop').remove();
  setTimeout(getCartPrice,200);
});



