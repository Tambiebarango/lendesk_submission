# frozen_string_literal: true

class Api::UsersController < ApplicationController
  skip_before_action :authenticate_request

  def create
    @user = User.new(user_params)
    
    if @user.save
      render json: @user, only: [:username], status: :ok
    else
      render json: { errors: @user.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  private
    def user_params
      params.require(:user).permit(:username, :password)
    end
end
