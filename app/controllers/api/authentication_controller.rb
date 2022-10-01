class Api::AuthenticationController < ApplicationController
  skip_before_action :authenticate_request

  def create
    @user = User.find(params[:username])
    
    if @user && @user.authenticate(params[:password])
      token = JwtClient.encode(username: @user.username)

      render json: {
        token: token,
        exp: 7200,
        username: @user.username
      }, status: :ok
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  private

  def login_params
    params.permit(:username, :password)
  end
end
