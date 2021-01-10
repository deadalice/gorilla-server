class Source < ApplicationRecord
  # We need to sort by created instead of updated because of FlattenSourcesJob
  self.implicit_order_column = :created_at

  belongs_to :package

  has_one_attached :file, dependent: :purge_later

  validates :file,
            content_type: 'application/zip',
            size: { less_than: 1.gigabyte }

  def attach(**args)
    file.attach(args)
  end

  def generate_manifest(files: nil)
    self.manifest = {
      files: files
    }
  end

  def update_state(state: nil)
    Rails.cache.write("source_state_#{id}", expires_in: MODEL_CACHE_TIMEOUT)
  end
end
