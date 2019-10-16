const fetchBtn = document.querySelector("#btn_fetch_recipes");
const id = document.querySelector("#fetch_recipes").getAttribute('data');

$(fetchBtn).on('click', function() {
  // disable button
  $(this).prop("disabled", true);
  // add spinner to button
  $(this).html(
    `<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> chargement...`
  );
  $.ajax({
      url: "/lists/" + id +"/fetch_recipes",
      cache: false,
      success: function(){
      }
  });
})

$(fetchBtn).on('click', function() {
  setTimeout(hide, 1000);
})

function hide() {
  fetchBtn.style.display = "none";
}
