class IpoProfile < ApplicationRecord
  belongs_to :company
  extend FriendlyId
  friendly_id :symbol, use: :slugged
end
