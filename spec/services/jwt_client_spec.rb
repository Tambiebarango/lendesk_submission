# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "JwtClient" do
  around do |example|
    with_env("SECRET_KEY", "secret") do
      example.run
    end
  end
  
  before do
    allow(JWT).to receive(:encode)
    allow(JWT).to receive(:decode).and_return([{data: "payload"}])
  end

  describe "#self.encode" do
    it "should encode payload" do
      payload = { data: "payload" }
      JwtClient.encode(payload)

      expect(JWT).to have_received(:encode).at_least(:once).with(payload, "secret")
    end
  end
  
  describe "#self.decode" do
    it "should decode payload" do
      JwtClient.decode("token")

      expect(JWT).to have_received(:decode).at_least(:once).with("token", "secret")
    end
  end
end
