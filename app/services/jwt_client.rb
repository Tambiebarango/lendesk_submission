# frozen_string_literal: true

class JwtClient
  class << self
    def encode(payload)
      expiry = 2.hours.from_now.to_i
      payload[:expiry] = expiry

      JWT.encode(payload, ENV.fetch("SECRET_KEY"))
    end

    def decode(token)
      data = JWT.decode(token, ENV.fetch("SECRET_KEY"))[0]
      
      HashWithIndifferentAccess.new(data)
    end
  end
end
