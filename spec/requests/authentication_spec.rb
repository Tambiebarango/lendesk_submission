require 'rails_helper'

RSpec.describe "Authentication", type: :request do
  describe "#create" do
    let(:params) {
      {
        username: "test_user",
        password: "StrongPassword123!"
      }
    }

    context "when login invalid" do
      it "should return 401" do
        post "/authentication/login", params: params

        expect(response.status).to eq 401
      end
    end

    context "when login is valid" do
      it "should return token" do
        with_env("SECRET_KEY", "secret_key") do
          allow(JwtClient).to receive(:encode).and_return("token")
          user = User.create(username: "test_user", password: "StrongPassword123!")

          post "/authentication/login", params: params

          body = JSON.parse(response.body)
          expect(response.status).to eq 200
          expect(body["token"]).to eq "token"
          expect(body["exp"]).to eq 7200
          expect(body["username"]).to eq user.username
        end
      end
    end
  end
end
