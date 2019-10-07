const fetch = document.querySelector("#fetch_recipes");
const id = fetch.getAttribute('data');

$(fetch).ready(function() {
  $.ajax({
      url: "/food_lists/" + id +"/fetch_recipes",
      cache: false,
      success: function(){
      }
  });
})
