# frozen_string_literal: true

class Api::UsersController < ApplicationController
  skip_before_action :authenticate_request

  def create
    @user = User.create(
      username: user_params[:username],
      password: user_params[:password]
    )
    
    render json: @user.to_h, status: :ok
  rescue => e
    render json: { errors: e.message }, status: :unprocessable_entity
  end

  private
    def user_params
      params.require(:user).permit(:username, :password)
    end
end
