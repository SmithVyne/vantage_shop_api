require_dependency 'ParseFile'

class ResponsesController < ApplicationController
  def create
    # res = {response: {hi: "tsv_str"}}
    jsonShopData = ParseFile.new(params[:tsv]).response
    render json: jsonShopData, status: :created

    # unless jsonShopData.errors.count
    #   render json: jsonShopData.errors, status: :unprocessable_entity
    # else
    #   render jsonShopData: jsonShopData, status: :created
    # end
    
    # res = Read.new("What's up").message
    # render json: res, status: :created
  end
end
