# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "#create" do
    let(:params) { 
      {
        user: {
          username: "test_user",
          password: "StrongPassword123!"
        }

      }
    }

    context "when created with valid params" do
      it "should create a new user" do
        post "/api/users", params: params

        expect(response.status).to eq(200)
        result = User.find(params[:user][:username])
        expect(result.username).to eq "test_user"
      end
    end

    context "when params invalid" do
      it "should return 422" do
        params[:user][:password] = "notstrongenough"

        post "/api/users", params: params
        
        expect(response.status).to eq(422)
      end
    end
  end
end
