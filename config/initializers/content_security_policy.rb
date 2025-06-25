# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    # --- Default directives ---
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src  :self, :https
    policy.style_src   :self, :https

    # --- Custom directives ---
    # Allow "ith-workspace.thape.com.cn" to embed this app in an iframe.
    policy.frame_ancestors :self, "https://ith-workspace.thape.com.cn"

    # Specify URI for violation reports (optional)
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate session nonces for permitted importmap, inline scripts, and inline styles.
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w(script-src style-src)

  # Remove the legacy X-Frame-Options header so that the frame_ancestors directive is authoritative.
  config.action_dispatch.default_headers.delete('X-Frame-Options')

  # Report violations without enforcing the policy (set to true for report-only mode).
  # config.content_security_policy_report_only = true
end