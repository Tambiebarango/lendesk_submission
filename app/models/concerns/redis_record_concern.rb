# frozen_string_literal: true

module RedisRecordConcern
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def find_by(options = {})
      key = options.keys.first
      prefix = "#{self::REDIS_PREFIX}"

      return unless key

      result = RedisClient.hgetall("#{prefix}#{options[key]}")

      yield result
    end

    def create(*args)
      record = self.new(*args)

      if record.errors.any?
        msg = record.errors.full_messages.join(", ")
        raise msg
      end
      
      yield record
    end

    def save_to_redis(record, hash_name)
      variables = record.instance_variables
      args = [hash_name]
      variables.each do |var|
        clean_var = var.to_s.gsub("@", "")
        
        next if self::REDIS_BLOCKLIST.include?(clean_var)

        args << clean_var
        args << record.instance_variable_get(var)
      end
      
      RedisClient.hset(*args)
    end
  end
end
