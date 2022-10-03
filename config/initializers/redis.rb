# frozen_string_literal: true

case Rails.env
when "development"
  $redis = Redis.new
when "test"
  $redis = MockRedis.new
end