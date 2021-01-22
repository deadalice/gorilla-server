class User < ApplicationRecord
  include Blockable

  # Include default devise modules. Others available are:
  # :validatable, :confirmable, :lockable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :timeoutable,
         :lockable

  has_secure_token :authentication_token

  # Because of company support and installed packages we can't allow to delete resources
  # has_many (as on Git) OR belongs_to :group, optional: true
  has_many :packages, dependent: :destroy # TODO: :nullify
  has_many :endpoints, dependent: :destroy

  validates :email,
            presence: true,
            length: { maximum: MAX_EMAIL_LENGTH },
            uniqueness: { case_sensitive: false },
            format: { with: EMAIL_FORMAT }
  validates :username,
            name_restrict: true,
            presence: true,
            length: { minimum: MIN_NAME_LENGTH, maximum: MAX_NAME_LENGTH },
            uniqueness: { case_sensitive: false },
            format: { with: NAME_FORMAT }
  validates :authentication_token,
            length: { if: 24 }

  attr_accessor :endpoint

  # TODO: Everyone can create packages, but we need to add permissions for company members later

  def generate_username
    username = "#{self.email[/^[^@]+/]}"
    self.username = User.find_by(username: username).nil? ? username : "#{username}#{rand(10_000)}"
  end

  def active_for_authentication?
    super && !self.blocked?
  end

  def inactive_message
    !self.blocked? ? super : :blocked
  end
end
