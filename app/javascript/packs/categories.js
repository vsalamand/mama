import Rails from 'rails-ujs'
import 'bootstrap';


$(document).on("click" , ".unselectedCategory", function(event) {
  const id = this.getAttribute('data');

  $.ajax({
    url: "/categories/" + id + "/select",
    cache: false,
    success: function(){
    }
  });
})


$(document).on("click" , ".selectedCategory", function(event) {
  const id = this.getAttribute('data');

  $.ajax({
    url: "/categories/" + id + "/unselect",
    cache: false,
    success: function(){
    }
  });
})


//  Create new list item
$(document).on("click" , ".addCategoryToList", function(event) {
  var categoryName = this.getAttribute('data');

  var categoryId = this.getAttribute('data-id');
  var element = "#grocerylist-category-id" + categoryId
  document.querySelectorAll(element).forEach(e => e.remove());

  if(document.querySelector("#todo_list")) {
    var listId = document.querySelector("#todo_list").getAttribute('data');
    $.ajax({
      type: "POST",
      url: "/items?c=add",
      cache: false,
      dataType: 'script',
      data: {
          item: {
            name: categoryName
          },
          list_id: listId
          },
      success: function(){
      }
    });
  }
  if(document.getElementById('assistantContent')) {
    $.ajax({
      url: "/categories/select",
      cache: false,
      dataType: 'script',
      data: {
            c: categoryName
          },
      success: function(){
      }
    });
  }
});




// show / hide category
$(document).on("click", ".fetchCategory", function(event) {
  var categoryId = this.getAttribute('data-id');
  $('#contentModal').modal('show')
  $('#contentShow').html(
    `<span class="spinner-border spinner-border-lg m-5" role="status" aria-hidden="true"></span>`
  );
  if(document.querySelector("#todo_list")){
    var listId = document.querySelector("#todo_list").getAttribute('data');
    fetchCategory(listId, categoryId);
  } else {
    fetchSimilarContent(categoryId)
  }

})

function fetchCategory(listId, categoryId) {
  $.ajax({
    url: "/lists/" + listId + "/fetch_category",
    cache: false,
    dataType: 'script',
    data: {
        l: listId,
        c: categoryId
        },
    success: function(){
    }
  });
}

function fetchSimilarContent(categoryId) {
  $.ajax({
    url: "/categories/" + categoryId + "/fetch_similar",
    cache: false,
    dataType: 'script',
    data: {
        },
    success: function(){
    }
  });
}


// Show category modal
$(document).on("turbolinks:load", function(event) {
  if(document.getElementById("todo_list")) {
    var searchParams = new URLSearchParams(window.location.search)

    if (searchParams.get('type') === "category") {
      var listId = document.querySelector("#todo_list").getAttribute('data');
      var categoryId = searchParams.get('content');
      $('#contentModal').modal('show')
      $('#contentShow').html(
        `<span class="spinner-border spinner-border-lg m-5" role="status" aria-hidden="true"></span>`
      );

      fetchCategory(listId, categoryId);

    }
  }
})
