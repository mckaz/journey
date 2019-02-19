ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "capybara/rails"

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless disable-gpu window-size=1280,1024) }
  )

  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    desired_capabilities: capabilities
end

if ENV['CHROME']
  Capybara.javascript_driver = :chrome
else
  Capybara.javascript_driver = :headless_chrome
end
DatabaseCleaner.strategy = :truncation

require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

class Minitest::Test
  if ENV["TYPECHECK"]
    require_relative '../typecheck.rb'
  end
  if ENV["NODYNCHECK"]
    RDL::Config.instance.check_comp_types = false
    require_relative '../typecheck.rb'
  end

end

# TODO: JIPE can be kind of slow.  Increasing the wait time to work around it.
Capybara.default_max_wait_time = 5

class ActionController::TestCase
  include Devise::TestHelpers
end

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
  include Warden::Test::Helpers

  self.use_transactional_fixtures = false

  before do
    Warden.test_mode!
    DatabaseCleaner.start
  end

  teardown do
    Warden.test_reset!
    Capybara.current_driver = Capybara.default_driver
    DatabaseCleaner.clean
  end

  def save_and_open_screenshot
    @@screenshot_num ||= 0
    @@screenshot_num += 1

    page.driver.save_screenshot "tmp/screenshot-#{@@screenshot_num}.png"
    Launchy.open "tmp/screenshot-#{@@screenshot_num}.png"
  end
end
