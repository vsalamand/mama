 const hideViewMoreBtn = () => {
  document.querySelectorAll(".view-more").forEach((vm) => {
    vm.addEventListener("click", (event) => {
      event.currentTarget.style.display = "none";
    });
  });
 }

export { hideViewMoreBtn };
