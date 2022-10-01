# frozen_string_literal: true

class UniquenessValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add attribute, "must be unique" unless unique?(record)
  end

  private
    def unique?(record)
      !RedisClient.exists?(record.db_id)
    end
end
