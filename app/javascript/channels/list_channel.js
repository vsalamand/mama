const initListCable = () => {
  const listItemsContainer = document.getElementById('uncomplete_list_items');
  if (listItemsContainer) {
    const id = listItemsContainer.dataset.listId;

    if (!App[`list_${id}`]) {
      App[`list_${id}`] = App.cable.subscriptions.create(
        { channel: "ListChannel", list_id: id },
        {
        received(data) {
          if (data.action === "create") {
              refreshForm(data.message_partial_form);
              insert(data.store_section_name, data.message_partial_list_item);
            } else if (data.action === "delete") {
              const listItemId = data.item_id;
              const storeSection = data.store_section;
              deleteListItem(listItemId, storeSection);
            } else {
              const listItemId = data.item_id;
              refreshListItem(listItemId, data.message_partial);
            }
          getEditHistory(data.current_user_id);
        },
      });
    }
  }
}

export { initListCable };

function insert(store_section_name, new_partial) {
  const header = store_section_name + "Elements"
  const sectionElements = document.getElementById(header)
  sectionElements.insertAdjacentHTML('beforeend', new_partial);
  sortSectionElements(sectionElements);
}

function sortSectionElements(sectionElements) {
  const listItems = sectionElements.querySelectorAll(".listItemShow")
  const sortedListItems = $(listItems).sort((a,b)=>a.innerText.toLowerCase()>b.innerText.toLowerCase()?1:-1)
  const sortedSectionElements = $(sortedListItems).map(function() {
    sectionElements.appendChild(this);
  })
}


function refreshForm(form_partial) {
  const newListItemForm = document.getElementById('new_item');
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


function deleteListItem(listItemId, storeSection) {
  const listItemCard = document.querySelector("#grocerylist-item-id" + listItemId);
  listItemCard.remove();
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



