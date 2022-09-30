# frozen_string_literal: true

class ComplexValidator < ActiveModel::EachValidator
  COMPLEXITY_REGEX = /^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,70}$/

  def validate_each(record, attribute, value)
    record.errors.add attribute, "must be complex" unless complex?(value)
  end
  
  private
    def complex?(value)
      value.match? COMPLEXITY_REGEX      
    end
end
