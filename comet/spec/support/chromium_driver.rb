require "capybara/rspec"
require "selenium-webdriver"

Capybara.server = :puma
Capybara.register_driver :selenium_chrome_comet do |app|
  browser_options = Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.add_argument("--headless")
    opts.add_argument("--disable-gpu") if Gem.win_platform?
    # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
    opts.add_argument("--disable-site-isolation-trials")
    opts.add_argument("--window-size=1440,1440")
  end

  Capybara::Selenium::Driver.new(app, **{browser: :remote, url: ENV["HUB_URL"], timeout: ENV.fetch("SELENIUM_TIMEOUT", 30).to_i, capabilities: browser_options})
end

Capybara.server_host = IPSocket.getaddress(Socket.gethostname)
Capybara.default_max_wait_time = ENV.fetch("CAPYBARA_WAIT_TIME", 30).to_i # We may have a slow application, let's give it some time.
