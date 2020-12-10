class ApplicationController < ActionController::Base
  class_attribute :lark_client

  # self.lark_client = Lark::Client.connect

  def lark_client
    self.class.lark_client
  end
end
