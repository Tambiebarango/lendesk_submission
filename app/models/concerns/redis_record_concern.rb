# frozen_string_literal: true

module RedisRecordConcern
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def find_by(options = {})
      key = options.keys.first # we only want to support finding by one key

      return unless key

      result = RedisClient.hgetall(options[key])

      yield result
    end

    def create(*args)
      record = self.new(*args)

      if record.valid?
        yield record
      else
        msg = record.errors.full_messages.join(", ")

        raise msg
      end
    end

    def save_to_redis(record, hash_name)
      # maybe save to namespace by class
      variables = record.instance_variables
      args = [hash_name]
      variables.each do |var|
        clean_var = var.to_s.gsub("@", "")
        next if %w(password errors validation_context).include?(clean_var)

        args << clean_var
        args << record.instance_variable_get(var)
      end
      RedisClient.hset(*args)
    end
  end
end
