import Rails from 'rails-ujs'

const search = document.querySelector("#livesearch");

search.addEventListener("keyup", (event) => {
  event.preventDefault();
  // submit search form as JS
  Rails.fire(search, 'submit');
});
