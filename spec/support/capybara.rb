RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :remote_chrome
    Capybara.server_host = IPSocket.getaddress(Socket.gethostname)
    Capybara.server_port = 4444
    Capybara.app_host = "http://#{Capybara.server_host}:#{Capybara.server_port}"
  end

  # config.before(:each, type: :system, js: true) do
  #   driven_by :remote_chrome
  #   Capybara.server_host = IPSocket.getaddress(Socket.gethostname)
  #   Capybara.server_port = 4444
  #   Capybara.app_host = "http://#{Capybara.server_host}:#{Capybara.server_port}"
  # end
end

# Chrome
Capybara.register_driver :remote_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  url = 'http://chrome:4444/wd/hub'

  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--window-size=1400,1400')

  Capybara::Selenium::Driver.new(
    app,
    browser: :remote,
    url: url,
    options: options
  )
end
