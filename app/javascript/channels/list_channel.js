const initListCable = () => {
  const listItemsContainer = document.getElementById('uncomplete_list_items');
  if (listItemsContainer) {
    const id = listItemsContainer.dataset.listId;

    App[`list_${id}`] = App.cable.subscriptions.create(
      { channel: "ListChannel", list_id: id },
      {
      received(data) {
        if (data.action === "create") {
            refreshForm(data.message_partial_form);
            refreshList(data.message_partial_list);
          } else if (data.action === "delete") {
            const listItemId = data.list_item_id;
            const storeSection = data.store_section;
            deleteListItem(listItemId, storeSection);
          } else {
            const listItemId = data.list_item_id;
            refreshListItem(listItemId, data.message_partial);
          }
        getEditHistory(data.current_user_id);
      },
    });
  }
}

export { initListCable };


function refreshList(list_partial) {
  // reload content in grocerylist
  const uncompleteListItems = document.getElementById('uncomplete_list_items');
  uncompleteListItems.innerHTML = (list_partial);
}

function refreshForm(form_partial) {
  const newListItemForm = document.getElementById('new_list_item');
  newListItemForm.innerHTML = form_partial;
  var submitButton = document.getElementById('addListItemBtn');
  $(submitButton).prop('disabled', true);
  event.preventDefault();
}

function refreshListItem(listItemId, show_partial) {
  const listItemCard = document.querySelector("#grocerylist-item-id" + listItemId);
  listItemCard.innerHTML = "";
  listItemCard.innerHTML = (show_partial);
}


function updateCompletedHeader() {
  // show/hide header
  var completedCount = $("#complete_list_items li").length;
  const completedHeader = document.getElementById('completedListItemHeader');
  if(completedCount == 0){
    $(completedHeader).hide();
  } else {
    $(completedHeader).show();
  }
}

function updateSectionHeader(storeSection) {
  // show/hide header
  var header = "#" + storeSection + " li"
  var todolistSectionCount = $(header).length;
  var sectionHeader = document.getElementById(storeSection+"Header");

  if(todolistSectionCount === 0){
    updateCompletedHeader();
    $(sectionHeader).hide();
  } else {
    updateCompletedHeader();
    $(sectionHeader).show();
  }
}

function deleteListItem(listItemId, storeSection) {
  const listItemCard = document.querySelector("#grocerylist-item-id" + listItemId);
  listItemCard.remove();
  updateSectionHeader(storeSection);
}


function getEditHistory(current_user_id) {
  const listId = document.querySelector("#todo_list").getAttribute('data');

  $.ajax({
    url: "/lists/" + listId + "/get_edit_history",
    cache: false,
    data: {
      a: current_user_id
      },
    success: function(data){
    }
  });
}



