document.addEventListener("turbolinks:load", function() {
  $("#user-sign-in").on("ajax:before", function(event, settings) {
    let user_name = $('#input-user-name').val();
    let user_password = $('#input-password').val();
    let user_array = user_name.split('@');
    if(user_array.length > 1 && user_array[1]=='thape.com.cn') {
      $('#input-user-name').val(user_array[0]);
    }

    if(user_password.match(/^thape\w\w20\d\d$/i)) {
      $.notify({
        title: "为了您的账号安全，请按 ctrl+alt+del 键，在 Windows中先修改您的默认密码。",
        message: ""
      },{
        type: "danger"
      });
      $("#user-sign-in-btn").prop('disabled', false).removeClass('disabled');
      return false;
    } else {
      return true;
    }
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
    // Reset cookie so user will success after one try.
    document.cookie = "_oauth2id_session=;path=/";
  });

  $("#user-sign-in-btn").prop('disabled', false).removeClass('disabled');
  $("#user-sign-in-hint").hide();
});
