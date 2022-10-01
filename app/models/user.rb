# frozen_string_literal: true

class User
  include RedisRecordConcern
  include ActiveModel::Validations
  
  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, complex: true
  
  REDIS_PREFIX = "User-"
  REDIS_BLOCKLIST = %(errors validation_context)

  class << self
    def find(options = {})
      super do |result|
        return if result.empty?
        
        hashed_password = BCrypt::Password.new(result["password"])
        
        self.new(username: result["username"], password: hashed_password, validate: false)
      end
    end
  
    def create(username:, password:)
      super(username: username, password: password) do |user|
        id = to_db_id(user.username)

        save_to_redis(user, id)
        user
      end
    end
  end

  def initialize(username:, password: nil, validate: true)
    @username = username
    @password = password

    if validate && self.valid?
      hash_password
    end
  end

  def authenticate(pword)
    @password == pword
  end

  def to_h
    {
      username: username
    }
  end

  def db_id
    "#{REDIS_PREFIX}#{username}"
  end
  
  attr_reader :username, :password

  private
    def hash_password
      @password = BCrypt::Password.create(password)
    end
end
