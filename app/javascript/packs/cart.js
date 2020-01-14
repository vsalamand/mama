import Rails from 'rails-ujs'
import 'bootstrap';

// document.addEventListener('click', function(event) {
//   event.stopImmediatePropagation();
//   console.log('hey')

//   const cartId = document.querySelector(".cartItemShow").getAttribute('data');
//   const id = event.currentTarget.id;

//   $.ajax({
//     url: "/carts/" + cartId + "/cart_items/" + id,
//     type: "DELETE"
//   });
// })


// open Add product modal when click on button
$(document).on('click', '#addProducts', function() {
  $('#addProductsModal').modal('show');
})

// close modal when list item is submitted
$(document).on('click', '.buyBtn',function() {
  $('#addProductsModal').modal('hide');
});


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
