class ResponsesController < ApplicationController
  def create
    jsonShopData = ParseFile.new(params[:tsv]).response
    render json: jsonShopData, status: :created

    # unless jsonShopData.errors.count
    #   render json: jsonShopData.errors, status: :unprocessable_entity
    # else
    #   render jsonShopData: jsonShopData, status: :created
    # end
  end
end
