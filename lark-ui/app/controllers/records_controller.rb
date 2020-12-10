class RecordsController < ApplicationController
  def show
    @record = lark_client.get(params.require(:id))
  end
end
