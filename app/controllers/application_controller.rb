# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :authenticate_request

  private
    def authenticate_request
      header = request.headers['Authorization']
      user = JwtClient.decode(header)
      
      unless RedisClient.exists?(user[:username])
        render json: { message: "Unauthorized" }, status: :unauthorized
      end
    rescue JWT::DecodeError => e
      render json: { message: "Unauthorized" }, status: :unauthorized
    end
end
