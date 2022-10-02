# frozen_string_literal: true

class User
  include RedisRecordConcern
  include ActiveModel::Validations
  
  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, complex: true
  
  REDIS_PREFIX = "User-"
  REDIS_BLOCKLIST = %w(errors validation_context)

  class << self
    def find(options = {})
      super do |result|
        return if result.empty?
        
        # password on the user record returned from redis is a string form of the bcrypt hash
        # to be able to compare it using ==, need to re-initialize BCrypt::Password with the string

        hashed_password = BCrypt::Password.new(result["password"])
        
        # pass in validate: false because no need to run validations
        # we only need to initialize User in order to be able to authenticate the password
        
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

    if password.present? && validate && self.valid?
      # only hash the password if there is a password, validate is true and the user is valid
      
      hash_password
    end
  end

  def correct_password?(pword)
    # @password is a BCrypt::Password hash

    @password == pword
  end

  def to_h
    {
      username: username
    }
  end

  def db_id
    self.class.to_db_id(username)
  end
  
  attr_reader :username, :password

  private
    def hash_password
      @password = BCrypt::Password.create(password)
    end
end
