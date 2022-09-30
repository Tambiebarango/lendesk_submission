# frozen_string_literal: true

class UniquenessValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add attribute, "must be unique" unless unique?(record, value)
  end

  private
    def unique?(record, value)
      !RedisClient.exists?(value)
    end
end
