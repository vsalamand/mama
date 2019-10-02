 const IncrementCounter = () => {
  document.querySelectorAll(".add-item").forEach((add) => {
    add.addEventListener("click", (event) => {
      let newCounter = parseInt(document.querySelector(".grocerylist-count").innerHTML) + 1;
      document.querySelectorAll(".grocerylist-count").forEach((counter) => {
        counter.innerHTML = newCounter;
      });
    });
  });
 }

export { IncrementCounter };
