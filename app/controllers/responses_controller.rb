class ResponsesController < ApplicationController
  def create
    jsonShopData = ParseFile.new(params[:tsv]).response
    render json: jsonShopData, status: jsonShopData[:errors].count ? :unprocessable_entity : :created

    # unless jsonShopData[:errors].count
    #   render json: jsonShopData.errors, status: :unprocessable_entity
    # else
    #   render jsonShopData: jsonShopData, status: :created
    # end
  end
end
