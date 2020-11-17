require 'rails_helper'

RSpec.describe StockTicker, type: :model do
  it { should validate_uniqueness_of(:ticker) }
  it { should have_one(:ipo_profile) }
  it { should have_one(:company) }
end
