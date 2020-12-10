import Rails from 'rails-ujs'
import 'bootstrap';



$(document).on('click', '#startAuthenticationBtn',function() {
  var context = this.getAttribute('data');

  $.ajax({
    url: "/start",
    cache: false,
    data: {
          c: context
        },
    success: function(data){
    }
  });

  $('#authenticationModal').modal('show');
  $('#authenticationModal').on('shown.bs.modal', function() {
    $('#startInputEmail').trigger('focus');
  });

  ahoy.track("Start authentication");
});

$(document).on('submit', '#startAuthentication',function(e) {
  e.preventDefault();
  var context = this.getAttribute('data-context');
  var email = document.getElementById('startInputEmail').value.trim()
  $.ajax({
    url: "/check_user",
    cache: false,
    data: {
          e: email,
          c: context
        },
    success: function(data){
    }
  });
});

