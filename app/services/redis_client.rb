# frozen_string_literal: true

class RedisClient
  class << self
    def method_missing(name, *args, &block)
      redis.send(name, *args, &block)
    end

    def hset(hash, *field_values)
      # override `hset` method by wrapping it in a transaction
      # so that db pks (hash) uniqueness can be enforced
      redis.multi
      redis.hset(hash, *field_values)
      redis.exec
    end

    private
      def redis
        $redis
      end
  end
end
