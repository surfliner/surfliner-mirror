Capybara.register_driver :selenium_standalone_chrome_headless_sandboxless do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :remote,
    desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: {
        args: %w[disable-gpu no-sandbox whitelisted-ips disable-dev-shm-usage headless window-size=1440,1440]
      }
    ),
    url: ENV["HUB_URL"]
  )
end

Capybara.server_host = IPSocket.getaddress(Socket.gethostname)
Capybara.server_port = ENV["CAPYBARA_PORT"]
