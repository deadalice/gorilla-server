class Source < ApplicationRecord
  include Blockable
  include Publishable
  include IdentityCache

  translates :description, :caption

  belongs_to :package, touch: true
  belongs_to :ancestor, class_name: "Source", optional: true
  has_one_attached :file,
                   service: :external,
                   dependent: :purge_later
  delegate :user, to: :package

  validates :file,
            content_type: "application/zip",
            size: {
              less_than: MAX_FILE_SIZE,
            }
  validates :caption,
            length: {
              maximum: MAX_NAME_LENGTH,
            }
  validates :description,
            length: { maximum: MAX_DESCRIPTION_LENGTH }
  validates :version, length: { maximum: MAX_VERSION_LENGTH }
  validates_with SourceValidator

  # GoldiLoader: includes(file_attachment: :blob)
  scope :preloaded, -> {
    joins(package: :user, file_attachment: :blob)
  }

  def self.merged?
    last&.merged?
  end

  private

  def check_publishable
    file.attached? && files.present? && files.size.positive?
  end
end
