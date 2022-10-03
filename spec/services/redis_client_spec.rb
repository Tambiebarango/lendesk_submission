# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "RedisClient" do
  describe "#self.hset" do
    context "when record is unique" do
      it "should set key in redis" do
        RedisClient.hset("hash", "key", "value")

        expect($redis.hgetall("hash")).to eq({"key" => "value"})
      end
    end

    context "when record is not unique" do
      it "should raise error" do
        RedisClient.hset("hash", "key", "value")

        expect {
          RedisClient.hset("hash", "key", "value")
        }.to raise_error(RuntimeError, /Record must be unique/)
      end
    end
  end
end
