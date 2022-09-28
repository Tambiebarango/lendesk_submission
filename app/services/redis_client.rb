# frozen_string_literal: true

class RedisClient
  class << self
    def get(key)
      redis.get(key)
    end

    def set(key, value)
      redis.set(key, value)
    end

    def expire(key, time)
      redis.expire(key, time)
    end

    def exists?(key)
      redis.exists(key) == 1
    end

    private
      def redis
        $redis
      end
  end
end
