import Rails from 'rails-ujs'
import 'bootstrap';


// Refresh product recommendations
$(document).on("click" , "#refreshAssistant", function(event) {
   // disable button
  $(this).prop("disabled", true);
  // add spinner to button
  $(this).html(
    `<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> chargement...`
  );

  var selectedCategories = document.querySelectorAll(".selectedCategory");
  var categories = []
  $(selectedCategories).map(function() {
                   categories.push($(this).text().trim());
                })

  $.ajax({
    url: "/refresh_assistant",
    cache: false,
    data: {
      c: categories
    },
    success: function(data) {
    }
  });

})

// Refresh product recommendations
$(document).on("click" , "#refreshMeal", function(event) {
   // disable button
  $(this).prop("disabled", true);
  // add spinner to button
  $(this).html(
    `<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> chargement...`
  );

  $.ajax({
    url: "/refresh_meal",
    cache: false,
    success: function(data) {
    }
  });

})

// update background color
var colors = ['linear-gradient(90deg, rgb(37, 163, 10),rgb(138, 191, 54),rgb(239, 219, 97))','linear-gradient(0deg, rgb(249, 66, 6),rgb(250, 134, 22),rgb(251, 202, 37))','linear-gradient(135deg, rgb(172, 76, 34),rgb(205, 125, 36),rgb(237, 173, 37))','linear-gradient(45deg, rgb(252, 169, 90),rgb(162, 85, 124),rgb(71, 0, 157))','linear-gradient(135deg, rgba(238, 238, 238, 0.1),rgba(16, 16, 16, 0.1)),linear-gradient(183deg, rgb(202, 255, 50),rgb(223, 14, 20))','linear-gradient(37deg, rgb(32, 218, 233),rgb(40, 21, 236))','linear-gradient(62deg, rgb(233, 121, 112),rgb(213, 192, 80))','linear-gradient(353deg, rgb(242, 82, 69),rgb(131, 28, 80))','linear-gradient(3deg, rgb(249, 144, 110),rgb(225, 14, 225))','linear-gradient(80deg, rgb(233, 222, 155),rgb(110, 153, 20))','linear-gradient(90deg, rgb(243, 114, 209) 0%,rgb(44, 19, 241) 100%)','linear-gradient(90deg, rgb(114, 7, 74),rgb(232, 54, 104))','linear-gradient(90deg, rgb(160, 222, 219),rgb(3, 165, 209))','linear-gradient(90deg, rgb(212, 91, 106),rgb(255, 224, 123))','linear-gradient(90deg, rgb(237, 228, 100),rgb(252, 152, 51))','linear-gradient(90deg, rgb(90, 35, 81),rgb(207, 104, 69))','linear-gradient(90deg, rgb(223, 90, 189),rgb(140, 2, 153))','linear-gradient(90deg, rgb(62, 25, 113),rgb(72, 105, 206))','linear-gradient(90deg, rgb(43, 77, 130),rgb(40, 144, 172))','linear-gradient(90deg, rgb(165, 5, 189),rgb(239, 87, 203))','linear-gradient(90deg, rgb(68, 144, 190),rgb(251, 254, 241))','linear-gradient(90deg, rgb(183, 57, 12),rgb(229, 127, 73))','linear-gradient(90deg, rgb(251, 114, 182),rgb(85, 22, 132))','linear-gradient(90deg, rgb(190, 90, 247),rgb(22, 91, 145))','linear-gradient(45deg, rgba(130, 89, 219, 0.2),rgba(44, 192, 226, 0.2),rgba(182, 103, 181, 0.2)),linear-gradient(135deg, rgb(39, 20, 149),rgb(65, 82, 185),rgb(91, 144, 220))','linear-gradient(145deg, rgba(232, 87, 237, 0.15) 0%,rgba(109, 137, 69, 0.15) 100%),linear-gradient(75deg, rgb(33, 138, 184),rgb(0, 241, 181))','linear-gradient(56deg, rgba(43, 46, 224, 0.15) 0%,rgba(26, 218, 182, 0.15) 100%),linear-gradient(336deg, rgb(50, 52, 221),rgb(60, 239, 241))','linear-gradient(241deg, rgba(18, 99, 158, 0.15) 0%,rgba(28, 247, 0, 0.15) 100%),linear-gradient(194deg, rgb(223, 130, 32),rgb(244, 244, 132))','linear-gradient(0deg, rgba(4, 223, 34, 0.15) 0%,rgba(167, 179, 214, 0.15) 100%),linear-gradient(90deg, rgb(210, 94, 235),rgb(219, 158, 203))','linear-gradient(0deg, rgba(80, 24, 135, 0.15) 0%,rgba(39, 228, 25, 0.15) 100%),linear-gradient(90deg, rgb(210, 135, 64),rgb(244, 195, 38))','linear-gradient(0deg, rgba(26, 228, 244, 0.15) 0%,rgba(50, 206, 35, 0.15) 100%),linear-gradient(90deg, rgb(44, 56, 250),rgb(88, 219, 228))','linear-gradient(0deg, rgba(168, 105, 74, 0.15) 0%,rgba(49, 77, 202, 0.15) 100%),linear-gradient(90deg, rgb(88, 1, 221),rgb(53, 46, 111))','linear-gradient(0deg, rgba(71, 224, 17, 0.15) 0%,rgba(159, 153, 81, 0.15) 100%),linear-gradient(90deg, rgb(5, 10, 46),rgb(251, 85, 78))','linear-gradient(0deg, rgba(216, 28, 10, 0.3) 0%,rgba(255, 189, 248, 0.3) 100%),linear-gradient(90deg, rgb(208, 18, 218),rgb(197, 126, 179))','linear-gradient(0deg, rgba(99, 109, 81, 0.3) 0%,rgba(198, 203, 94, 0.3) 100%),linear-gradient(90deg, rgb(18, 116, 125),rgb(20, 216, 80))','linear-gradient(135deg, rgb(195, 39, 2) 0%,rgb(224, 164, 60) 100%)','linear-gradient(135deg, rgb(191, 152, 26) 0%,rgb(216, 90, 24) 100%)','linear-gradient(135deg, rgb(68, 202, 201) 0%,rgb(252, 255, 114) 100%)','linear-gradient(90deg, rgb(54, 181, 183) 0%,rgb(19, 126, 105) 100%)','linear-gradient(0deg, rgb(61, 103, 216),rgb(65, 80, 170),rgb(53, 69, 115))','linear-gradient(90deg, rgb(217, 184, 42) 0%,rgb(131, 178, 27) 31%,rgb(45, 172, 11) 100%)','linear-gradient(135deg, rgb(245, 177, 77),rgb(237, 53, 115))','linear-gradient(45deg, rgb(217, 134, 15),rgb(225, 99, 66))','linear-gradient(45deg, rgb(56, 120, 78),rgb(175, 255, 102))','linear-gradient(45deg, rgb(51, 138, 249),rgb(47, 248, 255))','linear-gradient(90deg, rgb(215, 125, 57),rgb(184, 86, 67))','linear-gradient(90deg, rgb(235, 216, 9),rgb(202, 60, 134))','linear-gradient(0deg, rgb(94, 5, 4),rgb(253, 19, 61))','linear-gradient(90deg, rgb(247, 14, 199),rgb(24, 34, 250))','linear-gradient(0deg, rgb(176, 207, 255),rgb(92, 104, 168))','linear-gradient(45deg, rgb(40, 23, 76),rgb(232, 90, 94))','linear-gradient(90deg, rgb(109, 192, 190),rgb(11, 73, 25))','linear-gradient(90deg, rgb(84, 21, 156),rgb(132, 51, 77))','linear-gradient(90deg, rgb(1, 198, 86),rgb(47, 152, 24))','linear-gradient(90deg, rgb(223, 123, 141),rgb(188, 69, 32))','linear-gradient(90deg, rgb(217, 198, 252),rgb(82, 114, 237))','linear-gradient(45deg, rgb(139, 59, 210),rgb(47, 30, 152))','linear-gradient(0deg, rgb(113, 136, 223),rgb(17, 213, 207))','linear-gradient(135deg, rgb(57, 42, 4),rgb(210, 94, 97))','linear-gradient(90deg, rgb(119, 14, 191),rgb(238, 141, 125))','linear-gradient(90deg, rgb(116, 216, 252),rgb(156, 153, 254))','linear-gradient(0deg, rgb(238, 4, 44),rgb(202, 203, 40))','linear-gradient(45deg, rgb(241, 169, 36),rgb(1, 201, 13))','linear-gradient(0deg, rgb(112, 84, 203),rgb(232, 47, 180))','linear-gradient(90deg, rgb(234, 224, 68),rgb(51, 96, 57))','linear-gradient(135deg, rgb(32, 186, 230),rgb(110, 6, 173))','linear-gradient(45deg, rgb(140, 85, 250) 0%,rgb(200, 215, 253) 75%,rgb(143, 230, 243) 100%)','linear-gradient(90deg, rgb(79, 30, 218) 0%,rgb(104, 100, 218) 33%,rgb(35, 219, 162) 100%)','linear-gradient(90deg, rgb(119, 209, 210) 0%,rgb(174, 202, 76) 58%,rgb(231, 139, 28) 100%)','linear-gradient(45deg, rgb(221, 15, 86),rgb(198, 192, 66))','linear-gradient(135deg, rgb(185, 223, 103),rgb(253, 39, 50))','linear-gradient(45deg, rgb(89, 6, 184),rgb(246, 151, 67))','linear-gradient(90deg, rgb(26, 16, 35),rgb(12, 216, 57))','linear-gradient(0deg, rgb(246, 19, 218),rgb(2, 28, 51))','linear-gradient(45deg, rgb(43, 33, 93),rgb(81, 240, 237))','linear-gradient(0deg, rgb(85, 217, 233),rgb(86, 73, 252))','linear-gradient(45deg, rgb(18, 88, 19),rgb(40, 226, 59))','linear-gradient(135deg, rgb(182, 244, 85),rgb(63, 128, 87))','linear-gradient(0deg, rgb(217, 153, 41),rgb(211, 4, 236))','linear-gradient(90deg, rgb(111, 34, 83),rgb(253, 64, 149))','linear-gradient(90deg, rgb(252, 108, 53),rgb(170, 18, 159))','linear-gradient(90deg, rgb(171, 118, 76),rgb(235, 193, 30))','linear-gradient(90deg, rgb(234, 208, 36),rgb(134, 205, 157))'];
$(document).on("turbolinks:load", function(event) {
  if(document.getElementById("assistantWrapper")) {
    changeBackground(colors);
  }
})

function changeBackground(colors) {
  var color = colors[Math.floor(Math.random() * colors.length)];
  document.getElementById("assistantWrapper").style.background = color;
}






// show / hide recipe show
$(document).on("click", "#toggleRecipeShow", function(event) {
  showRecipe();
})
$(document).on("click", "#hideRecipeShow", function(event) {
  hideRecipe();
})

function showRecipe() {
  var recipeShow = document.getElementById('recipeOverlay');
  recipeShow.style.display = "block";
  setStoreSectionHeaders();
  var wrapper = document.getElementById('assistantMeal');
  wrapper.style.display = "none";
}

function hideRecipe() {
  var recipeShow = document.getElementById('recipeOverlay');
  recipeShow.style.display = "none";
  var wrapper = document.getElementById('assistantMeal');
  wrapper.style.display = "block";
}

// show / hide section headers
function setStoreSectionHeaders() {
  if(document.getElementById("recipeItems")) {
    var headers = document.querySelectorAll('.listHeader');
    $(headers).map(function() {
     var count = $(this).find('li').length;
      if(count === 0){
         this.style.display = "none";
      } else {
         this.style.display = "block";
      }
    })
  }
}