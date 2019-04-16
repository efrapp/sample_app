class User < ApplicationRecord
  attr_accessor :remember_token

  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
    format: { with: VALID_EMAIL_REGEX },
    uniqueness: { case_sensitive: false }

  has_secure_password
  # Here allow_nil is accepted because we want the edit form allows the
  # the password to be empty but has_secure_password has an internal
  # validation for this that only affects the signup form because when
  # we are trying to create a new user the password can't be empty but
  # when we are editing it the password field already has a password in
  # the database so the internal validation is not verified for it.
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  class << self
    # The porpouse of this method is to add a digest password to the users
    # created in the fixtures file. It is also used to create the remember
    # digest for the remember token.
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : 
                                                    BCrypt::Engine.cost
      
      BCrypt::Password.create(string, cost: cost)
    end

    def new_token
      SecureRandom.urlsafe_base64 
    end
  end

  def remember
    self.remember_token = User.new_token
    self.update_attribute(:remember_digest, User.digest(self.remember_token))
  end

  def authenticated?(remember_token)
    return false if self.remember_digest.nil?
    BCrypt::Password.new(self.remember_digest).is_password?(remember_token)
  end

  def forget
    self.update_attribute(:remember_digest, nil)
  end
end
