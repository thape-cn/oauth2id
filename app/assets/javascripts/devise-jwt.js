document.addEventListener("turbolinks:load", function() {
  $("#user-sign-in").on("ajax:beforeSend", function(event, settings) {
    const xhr = event.detail[0];
    xhr.setRequestHeader('JWT-AUD', 'oauth2id');
  });
  $("#user-sign-in-btn").prop('disabled', false).removeClass('disabled');
  $("#user-sign-in-hint").hide();
});
