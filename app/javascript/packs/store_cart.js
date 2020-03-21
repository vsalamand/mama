import Rails from 'rails-ujs'
import 'bootstrap';


// $(document).on("turbolinks:load", function(event) {
//   getStoreCartPrice();
// })

// function getStoreCartPrice() {
//   if(document.querySelector("#storeCartPrice")){
//     const storeId = document.querySelector("#storeId").getAttribute('data');
//     const storeCartId = document.querySelector("#storeCartShow").getAttribute('data');

//     $.ajax({
//       url: "/stores/" + storeId + "/store_carts/" + storeCartId +"/fetch_price",
//       cache: false,
//       success: function(){
//       }
//     });

//   }
// }



// close update product modal when list item is submitted
$(document).on('click', '.selectBtn',function() {
  $('.modal').modal('hide');
  $(document.body).removeClass('modal-open');
  $('.modal-backdrop').remove();
  // setTimeout(getStoreCartPrice,500);
});

// // close update product modal when list item is submitted
// $(document).on('click', '.deleteBtn',function() {
//   setTimeout(getStoreCartPrice,500);
// });


$(document).on('click', '.StoreCartItemShow', function(e) {
  const storeItemId = this.getAttribute('data2');
  const updateModal = "#updateProductModal" + storeItemId
  const storeCartId = document.querySelector("#storeCartShow").getAttribute('data');
  const storeCartItemId = this.getAttribute('data');

  var modalSpinner = document.querySelectorAll('#modalSpinner');
  $(modalSpinner).show();

  $.ajax({
    url: "/store_carts/" + storeCartId + "/store_cart_items/" + storeCartItemId + "/fetch_index",
    cache: false,
    success: function(){
      $(modalSpinner).hide();
    }
  });
});


$(document).on("turbolinks:load", function(event) {
  getCartsPrice();
  getStoreCartItems();
})


function getCartsPrice() {
  if(document.querySelector("#indexStoreCart")){
    const id = document.querySelector("#indexStoreCart").getAttribute('data');
    var storeCarts = document.getElementById('storeCarts');
    var modalSpinner = document.querySelectorAll('#modalSpinner');

    $(storeCarts).hide();
    $(modalSpinner).show();

    $.ajax({
      url: "/store_carts/fetch_price?list_id=" + id,
      cache: false,
      success: function(){
        $(storeCarts).show();
        $(modalSpinner).hide();
      }
    });

  }
}

function getStoreCartItems() {
  if(document.querySelector("#storeCartShow")){
    const id = document.querySelector("#storeCartShow").getAttribute('data');
    var content = document.getElementById('storeCartContent');
    var modalSpinner = document.querySelectorAll('#modalSpinner');

    $(content).hide();
    $(modalSpinner).show();

    $.ajax({
      url: "/store_carts/" + id + "/fetch_items",
      cache: false,
      success: function(){
        $(content).show();
        $(modalSpinner).hide();
      }
    });

  }
}

// // open modal when loading new store cart
$(document).on('click', '#loadStoreCartBtn', function() {
  $('#loadStoreCartModal').modal('show');
  $(modalSpinner).show();
})

$(document).on('click', '#loadCartBtn', function() {
  $('#loadCartModal').modal('show');
  $(modalSpinner).show();
})
