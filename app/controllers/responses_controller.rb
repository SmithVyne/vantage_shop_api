class ResponsesController < ApplicationController
  # before_action :set_response, only: [:show]

  # # GET /responses/1
  # def show
  #   render json: @response
  # end

  # POST /responses
  def create
    jsonShopData = Response.parseAsFile(params[:tsv])
    @response = Response.create({response: jsonShopData})

    if jsonShopData
      render json: jsonShopData, status: :created
    else
      render json: jsonShopData.errors, status: :unprocessable_entity
    end

    
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_response
    #   @response = Response.find_by(params[:id])
    # end
end
