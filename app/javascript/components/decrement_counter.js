 const DecreaseCounter = () => {
  document.querySelectorAll(".remove-item").forEach((remove) => {
    remove.addEventListener("click", (event) => {
      let newCounter = parseInt(document.querySelector(".grocerylist-count").innerHTML) - 1;
      document.querySelectorAll(".grocerylist-count").forEach((counter) => {
        counter.innerHTML = newCounter;
      });
    });
  });
 }

export { DecreaseCounter };
