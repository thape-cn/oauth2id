document.addEventListener("turbolinks:load", function() {
  "use strict";

  var treeviewMenu = $('.app-menu');

  // Toggle Sidebar
  $('[data-toggle="sidebar"]').click(function(event) {
    event.preventDefault();
    $('.app').toggleClass('sidenav-toggled');
  });

  // Activate sidebar treeview toggle
  $("[data-toggle='treeview']").click(function(event) {
    event.preventDefault();
    if(!$(this).parent().hasClass('is-expanded')) {
      treeviewMenu.find("[data-toggle='treeview']").parent().removeClass('is-expanded');
    }
    $(this).parent().toggleClass('is-expanded');
  });

  // Set initial active toggle
  $("[data-toggle='treeview.'].is-expanded").parent().toggleClass('is-expanded');

  //Activate bootstrip tooltips
  $("[data-toggle='tooltip']").tooltip();

  var notice_text = $('body').data('notice');
  if(notice_text) {
    $.notify({
      title: "Oauth2 Notice",
      message: notice_text,
      icon: 'fa fa-check'
    },{
      type: "info"
    });
  }
  var alert_text = $('body').data('alert');
  if(alert_text) {
    $.notify({
      title: "Oauth2 Alert",
      message: alert_text,
      icon: 'fa fa-alert'
    },{
      type: "warning"
    });
  }

  var copyButtons = document.querySelectorAll('[data-copy-target]');
  if (copyButtons.length) {
    for (var i = 0; i < copyButtons.length; i++) {
      copyButtons[i].addEventListener('click', function() {
        var target = document.getElementById(this.getAttribute('data-copy-target'));
        if (!target) {
          return;
        }
        target.focus();
        target.select();
        if (navigator.clipboard && navigator.clipboard.writeText) {
          navigator.clipboard.writeText(target.value);
        } else {
          document.execCommand('copy');
        }
        var copiedText = this.getAttribute('data-copied-text');
        var label = this.querySelector('span');
        if (copiedText && label) {
          label.textContent = copiedText;
        }
      });
    }
  }

  // Login Page Flipbox control
  $('.login-content [data-toggle="flip"]').click(function() {
    $('.login-box').toggleClass('flipped');
    return false;
  });
})
