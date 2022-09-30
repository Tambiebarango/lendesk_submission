# frozen_string_literal: true

class RedisClient
  class << self
    def method_missing(name, *args, &block)
      redis.send(name, *args, &block)
    end

    private
      def redis
        $redis
      end
  end
end
