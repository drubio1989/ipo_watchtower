class ApiKey < ApplicationRecord
  before_validation :generate_key, on: :create
  validates :secret_key, presence: true
  validates :active, presence: true

  scope :activated, -> { where(active: true) }

  def disable
    update_column :active, false
  end

  private

  def generate_key
    self.access_token = SecureRandom.hex
    self.secret_key = SecureRandom.hex
  end
end
