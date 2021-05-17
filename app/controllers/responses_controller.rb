class ResponsesController < ApplicationController
  def create
    @response = Response.find_by(uuid: params[:uuid])
    if @response
      jsonShopData = ParseFile.new(@response.tsv).response
      render json: {data: jsonShopData, tsv: @response.tsv}
    else
      jsonShopData = ParseFile.new(params[:tsv]).response
      @response = Response.create(response_params)
      render json: {data: jsonShopData, tsv: params[:tsv]}, status: jsonShopData[:errors].count > 0  ? :unprocessable_entity : :created
    end
  end

  private
  def response_params
    params.permit(:tsv, :uuid)
  end
end
