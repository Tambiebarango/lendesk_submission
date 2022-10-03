# frozen_string_literal: true

module RedisRecordConcern
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def find(pk)
      # Mimics active record's find method by searching redis
      # Each model will have its own pk
      # e.g. for the user model the pk is username
      
      return unless pk

      result = RedisClient.hgetall(to_db_id(pk))

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

    def save_to_redis(record, hash_name, action = "create")
      variables = record.instance_variables
      args = [action, hash_name]
      
      variables.each do |var|
        clean_var = var.to_s.gsub("@", "")
        
        # Classes that include this module must define a REDIS_BLOCKLIST
        # This will be an array of instance variables that should not be saved to redis
        # E.g. for the User model, the password and other instance variables defined by 
        # activemodel gem should not be saved to redis

        next if self::REDIS_BLOCKLIST.include?(clean_var)

        args << clean_var
        args << record.instance_variable_get(var)
      end
      
      RedisClient.hset(*args)
    end

    def to_db_id(pk)
      # Classes that include this module must define a REDIS_PREFIX
      # This will prefix the model's pk in redis.

      "#{self::REDIS_PREFIX}#{pk}"
    end
  end
end
