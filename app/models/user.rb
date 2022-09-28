class User < ApplicationRecord
  has_secure_password

  validates :username, presence: true, uniqueness: true
  validates :password, presence: true
  validate :password_complexity
  
  def password_complexity
    return if password =~ /^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,70}$/

    errors.add :password, 'should be between 8 and 70 characters and include: 1 uppercase, 1 lowercase, 1 digit and 1 special character'
  end
end
