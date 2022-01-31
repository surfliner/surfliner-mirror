##
# Support API actions for PCDM Objects
class ObjectsController < ApplicationController
  def show
    render json: GenericObject.new
  end
end
