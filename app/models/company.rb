class Company < ApplicationRecord
  has_one :ipo_profile, dependent: :destroy

  scope :name_starts_with_letter, -> (letter) { where("name LIKE ?", letter + '%') }
end
