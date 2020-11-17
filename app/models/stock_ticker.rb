class StockTicker < ApplicationRecord
  validates :ticker, uniqueness: true, unless: -> { ticker != 'TBA' }
  has_one :company, dependent: :destroy
  has_one :ipo_profile, through: :company
end
