// const html = ("<%= j render 'recommended_recipes', recipes_list: @recommended_recipes %>");
const fetchRecipes = document.querySelector("#fetch_recipes");
const id = fetchRecipes.getAttribute('data');

$.ajax({
    url: "/food_lists/" + id +"/add",
    cache: false,
    success: function(html){
      // fetchRecipes.innerHTML = html
    }
});
