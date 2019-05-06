class WechatsController < ApplicationController
  # For details on the DSL available within this file, see https://github.com/Eric-Guo/wechat#wechat_responder---rails-responder-controller-dsl
  wechat_responder

  on :batch_job, with: 'sync_user' do |request, batch_job|
    WechatEventHistory.create create_time: request[:CreateTime], event: request[:Event],
      change_type: 'sync_user', job_id: batch_job[:JobId], message: batch_job[:ErrMsg]
    request.reply.success
  end

  on :batch_job, with: 'replace_user' do |request, batch_job|
    WechatEventHistory.create create_time: request[:CreateTime], event: request[:Event],
      change_type: 'replace_user', job_id: batch_job[:JobId], message: batch_job[:ErrMsg]
    request.reply.success
  end

  on :batch_job, with: 'invite_user' do |request, batch_job|
    WechatEventHistory.create create_time: request[:CreateTime], event: request[:Event],
      change_type: 'invite_user', job_id: batch_job[:JobId], message: batch_job[:ErrMsg]
    request.reply.success
  end

  on :batch_job, with: 'replace_party' do |request, batch_job|
    WechatEventHistory.create create_time: request[:CreateTime], event: request[:Event],
      change_type: 'replace_party', job_id: batch_job[:JobId], message: batch_job[:ErrMsg]
    request.reply.success
  end
end
