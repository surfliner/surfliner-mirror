# frozen_string_literal: true

class RobotsController < ApplicationController
  # No layout
  layout false

  def index
    respond_to :text
  end
end
