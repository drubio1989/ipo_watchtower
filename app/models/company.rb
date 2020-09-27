class Company < ApplicationRecord
  has_one :ipo_profile, dependent: :destroy
end
