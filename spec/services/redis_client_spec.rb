# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "RedisClient" do
  describe "#self.get" do
    it "should get key from redis" do
      $redis.set("key", "value")

      expect(RedisClient.get("key")).to eq("value")
    end
  end
  
  describe "#self.set" do
    it "should set key in redis" do
      $redis.set("key", "value")

      expect(RedisClient.get("key")).to eq("value")
    end
  end

  describe "#self.expire" do
    it "should set key expiration in redis" do
      RedisClient.set("key", "value")
      RedisClient.expire("key", -1)

      expect(RedisClient.get("key")).to be_nil
    end
  end

  describe "#self.exists?" do
    context "when key exists" do
      it "should return true" do
        RedisClient.set("key", "value")

        result = RedisClient.exists?("key")

        expect(result).to be_truthy
      end
    end
    
    context "when key does not exist" do
      it "should return false" do
        result = RedisClient.exists?("key")

        expect(result).to be_falsey
      end
    end
  end
end
