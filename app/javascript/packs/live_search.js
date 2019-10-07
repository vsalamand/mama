import Rails from 'rails-ujs'


const search = document.querySelector("#livesearch");

search.addEventListener("keyup", (event) => {
  event.preventDefault();
  // submit search form as JS
  setTimeout(trigger_search,500);

});

const trigger_search = () => {
  Rails.fire(search, 'submit');
}
