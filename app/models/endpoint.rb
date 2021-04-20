class Endpoint < ApplicationRecord
  include Blockable

  has_secure_token :authentication_token
  # attribute :locale, :string, default: "en"
  attr_accessor :token

  belongs_to :user
  has_many :settings, dependent: :destroy
  has_many :packages, through: :settings

  validates :name,
            length: { maximum: MAX_NAME_LENGTH }
  validates :locale,
            length: { maximum: 10 }
  validates :authentication_token,
            allow_nil: true,
            length: { is: 24 }

  default_scope { joins(:user) }

  def installed?(package)
    settings.exists?(package: package)
  end

  def install(package)
    settings.create(package: package)
  end

  def reset_token
    if token.nil?
      regenerate_authentication_token
      self.token = JsonWebToken.encode(self)
    end
  end
end
