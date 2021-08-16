class Source < ApplicationRecord
  include Blockable
  include Publishable
  include IdentityCache

  attribute :size
  translates :description

  belongs_to :package, touch: true
  has_one_attached :file,
                   service: :external,
                   dependent: :purge_later

  delegate :user, to: :package

  validates :file,
            size: { less_than: MAX_FILE_SIZE }
  validates :description,
            length: { maximum: MAX_DESCRIPTION_LENGTH }
  validates :version,
            length: { maximum: MAX_VERSION_LENGTH }
  validates_with SourceValidator

  default_scope { includes(:file_attachment) }

  def self.merged?
    last&.is_merged == true
  end
end
