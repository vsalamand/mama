import Rails from 'rails-ujs'
import 'bootstrap';


$(document).on("turbolinks:load", function(event) {
  getStoreCartPrice();
})

$(document).on("DOMSubtreeModified", "#storeCartItemsList", function(event) {
  getStoreCartPrice();
})


function getStoreCartPrice() {
  if(document.querySelector("#storeCartPrice")){
    const id = document.querySelector("#storeCartPrice").getAttribute('data');
    const storeId = document.querySelector("#storeCartShow").getAttribute('data');

    $.ajax({
      url: "/stores/" + storeId + "/store_carts/" + id +"/fetch_price",
      cache: false,
      success: function(){
      }
    });

  }
}
