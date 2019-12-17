document.addEventListener("turbolinks:load", function() {
  $("#user-sign-in").on("ajax:before", function(event, settings) {
    let user_name = event.currentTarget[2].value
    let user_array = user_name.split('@');
    if(user_array.length > 1 && user_array[1]=='thape.com.cn') {
      event.currentTarget[2].value = user_array[0];
    }
    return true;
  });

  $("#user-sign-in").on("ajax:beforeSend", function(event, settings) {
    const xhr = event.detail[0];
    xhr.setRequestHeader('JWT-AUD', 'oauth2id');
  });

  $("#user-sign-in").on("ajax:error", function(event) {
    const detail = event.originalEvent.detail;
    $.notify({
      title: detail[1],
      message: detail[0],
      icon: 'fa fa-alert'
    },{
      type: "warning"
    });
    console.log(detail);
  });
  $("#user-sign-in-btn").prop('disabled', false).removeClass('disabled');
  $("#user-sign-in-hint").hide();
});
