require 'test_helper'
require 'warden/test/helpers'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include Warden::Test::Helpers

  # removes noisy logs when launching tests
  Capybara.server = :puma, { Silent: true }

  Capybara.register_driver :headless_chrome do |app|
    options = Selenium::WebDriver::Chrome::Options.new(args: %w[headless window-size=1400,1000])
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end

  driven_by(:headless_chrome)

  def setup
    super
    Warden.test_mode!
  end

  def teardown
    Warden.test_reset!
    super
  end
end
