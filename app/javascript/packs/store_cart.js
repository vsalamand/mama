import Rails from 'rails-ujs'
import 'bootstrap';


$(document).on("turbolinks:load", function(event) {
  getStoreCartPrice();
})

function getStoreCartPrice() {
  if(document.querySelector("#storeCartPrice")){
    const storeId = document.querySelector("#storeId").getAttribute('data');
    const storeCartId = document.querySelector("#storeCartShow").getAttribute('data');

    $.ajax({
      url: "/stores/" + storeId + "/store_carts/" + storeCartId +"/fetch_price",
      cache: false,
      success: function(){
      }
    });

  }
}



// close update product modal when list item is submitted
$(document).on('click', '.selectBtn',function() {
  $('.modal').modal('hide');
  $(document.body).removeClass('modal-open');
  $('.modal-backdrop').remove();
  setTimeout(getStoreCartPrice,500);
});



$(document).on('click', '.StoreCartItemShow', function(e) {
  const storeItemId = this.getAttribute('data2');
  const updateModal = "#updateProductModal" + storeItemId
  const storeId = document.querySelector("#storeId").getAttribute('data');
  const storeCartId = document.querySelector("#storeCartShow").getAttribute('data');
  const storeCartItemId = this.getAttribute('data');

  $.ajax({
    url: "/stores/" + storeId + "/store_carts/" + storeCartId + "/store_cart_items/" + storeCartItemId + "/fetch_index",
    cache: false,
    success: function(){
    }
  });

})

