# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "RedisClient" do
  describe "#self.hset" do
    context "when creating record" do
      context "when record is unique" do
        it "should set key in redis" do
          RedisClient.hset("create", "hash", "key", "value")

          expect($redis.hgetall("hash")).to eq({"key" => "value"})
        end
      end

      context "when record is not unique" do
        it "should raise error" do
          RedisClient.hset("action", "hash", "key", "value")

          expect {
            RedisClient.hset("create", "hash", "key", "value")
          }.to raise_error(RuntimeError, /Record must be unique/)
        end
      end
    end
  end
end
