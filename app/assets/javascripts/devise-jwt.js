document.addEventListener("turbolinks:load", function() {
  $("#user-sign-in").on("ajax:before", function(event) {
    let user_name = $('#input-user-name').val();
    let user_password = $('#input-password').val();
    let user_array = user_name.split('@');
    var today = new Date();
    var dayOfWeek = today.getDay();
    var currentHour = today.getHours();

    if(user_array.length > 1 && user_array[1]=='thape.com.cn') {
      $('#input-user-name').val(user_array[0]);
    }
    if(user_password.match(/^thape\w\w20\d\d$/i) && dayOfWeek > 0 && dayOfWeek < 6 && currentHour >= 11 && currentHour < 17) {
      $.notify({
        title: "为了您的账号安全，请按 ctrl+alt+del 键在 Windows 中先修改初始密码。",
        message: "密码长度至少 8 位，且至少包含以下 4 类字符中的 3 类（大写字母、小写字母、数字、符号），请勿使用 thape+ 字母/数字的格式。开机密码修改成功后可能需等待 15 分钟。"
      },{
        type: "danger"
      });
      $("#user-sign-in-btn").prop('disabled', false).removeClass('disabled');
      $("#qiye-web-login-btn").prop('disabled', false).removeClass('disabled');
      return false;
    } else {
      return true;
    }
  });

  $("#user-sign-in").on("ajax:beforeSend", function(event) {
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
    // Reset cookie so user will success after one try.
    document.cookie = "_oauth2id_session=;path=/";
  });

  $("#user-sign-in-btn").prop('disabled', false).removeClass('disabled');
  $("#qiye-web-login-btn").prop('disabled', false).removeClass('disabled');
  $("#user-sign-in-hint").hide();

  $("#qiye-web-login-btn").on('click', function(event) {
    var url = $(this).data('url');
    if(!url) { return; }

    // Build and submit a non-remote POST form to start OmniAuth flow
    var form = document.createElement('form');
    form.method = 'POST';
    form.action = url;
    form.style.display = 'none';

    // CSRF token (harmless if middleware ignores it)
    var csrfToken = $('meta[name="csrf-token"]').attr('content');
    var csrfParam = $('meta[name="csrf-param"]').attr('content') || 'authenticity_token';
    if (csrfToken) {
      var input = document.createElement('input');
      input.type = 'hidden';
      input.name = csrfParam;
      input.value = csrfToken;
      form.appendChild(input);
    }

    document.body.appendChild(form);
    form.submit();
  });
});
