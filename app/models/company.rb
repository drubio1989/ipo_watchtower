class Company < ApplicationRecord
  extend FriendlyId
  has_one :ipo_profile, dependent: :destroy
  friendly_id :name, use: :slugged
  scope :name_starts_with_letter, -> (letter) { where("name LIKE ?", letter + '%') }
end
