require 'read';

class ResponsesController < ApplicationController
  # before_action :set_response, only: [:show]

  def create
    # res = {response: {hi: "tsv_str"}}
    # jsonShopData = Response.parseAsFile(params[:tsv])
    # @response = Response.create({response: jsonShopData})

    # unless jsonShopData.errors.count
    #   render json: jsonShopData.errors, status: :unprocessable_entity
    # else
    #   render jsonShopData: jsonShopData, status: :created
    # end
    
    res = Read.new("What's up")
    render json: res, status: :created
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_response
    #   @response = Response.find_by(params[:id])
    # end
end
