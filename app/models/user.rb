class User
  include RedisRecordConcern
  include ActiveModel::Validations
  
  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, complex: true
  
  class << self
    def find_by(options = {})
      super do |result|
        return if result.empty?
        
        hashed_password = BCrypt::Password.new(result["password_digest"])
        
        self.new(username: result["username"], password_digest: hashed_password)
      end
    end
  
    def create(username:, password:)
      hashed_password = BCrypt::Password.create(password)

      super(username: username, password: password, password_digest: hashed_password) do |user|
        save_to_redis(user, user.username)
        user
      end
    end
  end

  def initialize(username:, password: nil, password_digest:)
    @username = username
    @password = password
    @password_digest = password_digest
  end

  def authenticate(password)
    @password_digest == password
  end

  def to_h
    {
      username: username
    }
  end
  
  attr_reader :username, :password_digest

  private
    attr_reader :password
end
