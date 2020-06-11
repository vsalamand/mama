/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// import Rails from 'jquery_ujs'
import 'bootstrap';

import ahoy from "ahoy.js";


import '../components/selectize';
import '../components/selectize1';

import 'packs/list';
import 'packs/cart';
import 'packs/store_cart';
import 'packs/recipe_lists';
import 'packs/recipes';
import 'packs/items';
import 'packs/pages';


// Service worker for progressive web app management
if (navigator.serviceWorker) {
  navigator.serviceWorker.register('/service-worker.js')
    .then(function(reg) {
      console.log('[Companion]', 'Service worker registered!');
      console.log(reg);
    });
}

// reload page when back online after being offline
window.addEventListener('offline', () => {
  console.log('Offline');
  window.addEventListener('online', () => {
   console.log('Online');
    location.reload();
  });
});


// Detect if PWA is installed
window.addEventListener('appinstalled', (e) =>{
  app.logEvent('a2hs', 'installed');
  ahoy.track("Webapp install");
});




// PWA prompt install on ANDROID
// Detects if device is on iOS
var android = /(android)/i.test(navigator.userAgent);
// Detects if device is in standalone mode
var isInStandaloneMode = window.matchMedia('(display-mode: standalone)').matches;


$(document).on("turbolinks:load", function(event) {
  if (android === true && isInStandaloneMode === false) {
    getInstallMessageAndroid();
  }
})

function getInstallMessageAndroid() {
  $.ajax({
    url: "/fetch_android_install",
    cache: false,
    data: {
      },
    success: function(data){
    }
  });
}

$(document).on('click', '#androidInstallBtn',function() {
  $('#installAndroidModal').modal('show');
});


// var deferredPrompt;

// window.addEventListener('beforeinstallprompt', (e) => {
//   // prevent earlier version of chrome 67 to automatically showing the prompt
//   e.preventDefault();
//   // Stash the event so it can be triggered later.
//   deferredPrompt = e;
//   var androidInstallBanner = document.getElementById("androidInstallBanner");
//   androidInstallBanner.style.display = "none";
// });

// $(document).on('click', '#androidInstallBtn', (e) => {
//   console.log('👍', 'butInstall-clicked');
//   const promptEvent = window.deferredPrompt;
//   if (!promptEvent) {
//     // The deferred prompt isn't available.
//     return;
//   }
//   // Show the install prompt.
//   promptEvent.prompt();
//   // Log the result
//   promptEvent.userChoice.then((result) => {
//     console.log('👍', 'userChoice', result);
//     // Reset the deferred prompt variable, since
//     // prompt() can only be called once.
//     window.deferredPrompt = null;
//   });
// });



//  PWA prompt install on IOS
// Detects if device is on iOS
var iOS = navigator.platform && /iPad|iPhone|iPod/.test(navigator.platform);
// Detects if browser is safari
var isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent);
// Detects if device is in standalone mode
var  isInStandaloneMode = window.matchMedia('(display-mode: standalone)').matches
// const isInStandaloneMode = () => ('standalone' in window.navigator) && (window.navigator.standalone);

// Checks if should display install popup notification:
// if (isIos() && !isInStandaloneMode()) {
  // this.setState({ showInstallMessage: true });
$(document).on("turbolinks:load", function(event) {
  if (iOS === true && isSafari === true && isInStandaloneMode === false && document.querySelector("#iOSInstallNavbar")) {
    getInstallMessageIOS();
  }
})

function getInstallMessageIOS() {
  $.ajax({
    url: "/fetch_ios_install",
    cache: false,
    data: {
      },
    success: function(data){
    }
  });
}

$(document).on('click', '#iOSInstallMessage',function() {
  $('#installiOSModal').modal('show');
});




//// Handle Turbolinks side-issues
// clear the cache often
$(document).on('ajax:before', '[data-remote]', () => {
  Turbolinks.clearCache();
});

// manage bootstrap modals
document.addEventListener('turbolinks:before-cache', () => {
  // Manually tear down bootstrap modals before caching. If turbolinks
  // caches the modal then tries to restore it, it breaks bootstrap's JS.
  // We can't just use bootstrap's `modal('close')` method because it is async.
  // Turbolinks will cache the page before it finishes running.
  if (document.body.classList.contains('modal-open')) {
    $('.modal')
      .hide();
    $('.modal-backdrop').remove();
    $(document.body).removeClass('modal-open');
  }
});


// make bootstrap dropdowns work with turbolinks
function toggleDropdown(element) {
  var dropdown = new Dropdown(element);
  dropdown.toggle();
}

document.addEventListener('turbolinks:load', function() {
  var dropdown_buttons = document.querySelectorAll('[data-toggle="dropdown"]');

  dropdown_buttons.forEach(function(element) {
    element.addEventListener('click', function(event) {
      event.preventDefault();

      toggleDropdown(this);
    });
  });
});

// close  modal after click
$(document).on('click', '#startGroceriesModal',function() {
  $('.modal').modal('hide');
});

// close  modal after click
$(document).on('click', '#openCreateModal',function() {
  $('.modal').modal('hide');
});

// close  modal after click
$(document).on('click', '#openCreateModal',function() {
  $('.modal').modal('hide');
});

// // close all modal after click on cross
$(document).on('click', '.closeModal',function() {
  $('.modal').modal('hide');
  $(document.body).removeClass('modal-open');
  $('.modal-backdrop').remove();
});

$(document).on('click', '#closeModalBtn',function(event) {
  $('.modal').modal('hide');
  $(document.body).removeClass('modal-open');
  // $('.modal-backdrop').remove();
});

// tracking signin / signup modal view
$(document).on("click", ".signupBtn", function(event) {
  var context = this.getAttribute('context');
  var action = this.getAttribute('action');
  ahoy.track("Signup modal", {context:  context, action: action});
})

$(document).on("click", ".goToSignupBtn", function(event) {
  ahoy.track("Signup page");
})

$(document).on("show.bs.modal", ".bd-login-modal-lg", function(event) {
  ahoy.track("Login modal");
})

document.addEventListener('turbolinks:load', function() {
  if(document.getElementById('loginPage')){
    ahoy.track("Login page");
  }
});

document.addEventListener('turbolinks:load', function() {
  if(document.getElementById('signupPage')){
    ahoy.track("Signup page");
  }
});

$(document).on("click", "#signout", function(event) {
  ahoy.track("Logout");
})


// tracking click on recipe links
$(document).on("click", ".recipeLinkClick", function(event) {
  var link = this.getAttribute('href')
  ahoy.track("Click recipe link", {link:  link});
})


// copy to clipboard
// Tooltip

$('button').tooltip({
  trigger: 'click',
  placement: 'bottom'
});

function setTooltip(btn, message) {
  $(btn).tooltip('hide')
    .attr('data-original-title', message)
    .tooltip('show');
}

function hideTooltip(btn) {
  setTimeout(function() {
    $(btn).tooltip('hide');
  }, 1000);
}

// Clipboard
document.addEventListener("turbolinks:load", function() {
  var clipboard = new Clipboard('.clipboard-btn');

  clipboard.on('success', function(e) {
    setTooltip(e.trigger, 'Copié!');
    ahoy.track("Copy link");
    hideTooltip(e.trigger);
  });

  clipboard.on('error', function(e) {
    setTooltip(e.trigger, 'Failed!');
    hideTooltip(e.trigger);
  });
})




//  Enable Continue to select list button in recipe and list views

$(document).on("turbolinks:load", function(event) {
  getListBtn();
})

$(document).on("DOMSubtreeModified", "#uncomplete_list_items", function(event) {
  getListBtn();
})

function getListBtn() {
  if(document.querySelector("#getListBtn")){
    var selectedItemsCount = document.querySelectorAll(".selectedItem").length;
    var btns = document.querySelectorAll("#getListBtn");
    if(selectedItemsCount > 0){
      $(btns).each(function() {
                      $(this).prop('disabled', false);
                    })
    } else {
      $(btns).each(function() {
                $(this).prop('disabled', true);
              })
    }
  }

}


