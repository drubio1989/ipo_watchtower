class StockTicker < ApplicationRecord
  has_one :company, dependent: :destroy
  has_one :ipo_profile, through: :company
end
