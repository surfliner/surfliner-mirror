class SearchController < ApplicationController
  def search
    @results = lark_client.search(params.require(:q))
  end
end
