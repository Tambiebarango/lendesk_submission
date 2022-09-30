# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "RedisClient" do
  describe "#self.hgetall" do
    it "should get key from redis" do
      $redis.hset("hash", "key", "value")

      expect(RedisClient.hgetall("hash")).to eq({"key" => "value"})
    end
  end
  
  describe "#self.hset" do
    it "should set key in redis" do
      RedisClient.hset("hash", "key", "value")

      expect($redis.hgetall("hash")).to eq({"key" => "value"})
    end
  end

  describe "#self.exists?" do
    context "when key exists" do
      it "should return true" do
        RedisClient.hset("hash", "key", "value")

        result = RedisClient.exists?("hash")

        expect(result).to be_truthy
      end
    end
    
    context "when key does not exist" do
      it "should return false" do
        result = RedisClient.exists?("hash")

        expect(result).to be_falsey
      end
    end
  end
end
