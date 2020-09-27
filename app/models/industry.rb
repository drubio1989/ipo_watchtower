class Industry < ApplicationRecord
  has_many :ipo_profiles, dependent: :destroy
  has_many :companies, through: :ipo_profiles
end
