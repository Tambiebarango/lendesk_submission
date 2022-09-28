# frozen_string_literal: true

require 'rails_helper'

include ActiveSupport::Testing::TimeHelpers

RSpec.describe "Foo", type: :request do
  describe "#show" do
    let(:headers) {
      {
        'Authorization' => 'token'
      }
    }
    let(:user_data) {
      {
        id: 1,
        username: 'foobar'
      }
    }
    let(:redis) { Redis.new }

    context "with invalid authorization" do
      context "no headers provided" do
        it "should return 401" do
          get "/foo"

          expect(response.status).to eq 401
        end
      end

      context "invalid token provided" do
        it "should return 401" do
          get "/foo", headers: { 'Authorization' => "poo" }

          expect(response.status).to eq 401
        end
      end
    end

    context "with valid authorization" do
      context "user cached data is not expired" do
        it "should return 'bar'" do
          allow(JwtClient).to receive(:decode).and_return({ username: "foobar" })
          $redis.set("foobar", 1)

          get "/foo", headers: headers

          body = JSON.parse(response.body)
          expect(response.status).to eq 200
          expect(body['foo']).to eq 'bar'
        end
      end

      context "when user cached data is expired" do
        it "should return 401" do
          allow(JwtClient).to receive(:decode).and_return({ username: "foobar" })
          $redis.set("foobar", 1)
          $redis.expire("foobar", -1)

          get "/foo", headers: headers

          expect(response.status).to eq(401)
        end
      end
    end
  end
end