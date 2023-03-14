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
        title: "无法继续，请按 ctrl+alt+del 键，在 Windows中先修改您的默认密码。",
        message: "\n SSO单点登录系统在任何情况下都不存储您的密码，但为了增强天华IT系统的整体安全性，SSO 刚刚在您的浏览器本地沙盒内尝试检测并发现您的密码符合天华默认密码规则，因此无法使用您的当前密码代理您继续登录。"
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
