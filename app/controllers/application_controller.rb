# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :authenticate_request

  private
    def authenticate_request
      header = request.headers['Authorization']
      data = JwtClient.decode(header)

      user = User.find(data[:username])
      
      unless user
        render json: { message: "Unauthorized" }, status: :unauthorized
      end
    rescue JWT::DecodeError => e
      render json: { message: "Unauthorized" }, status: :unauthorized
    end
end
