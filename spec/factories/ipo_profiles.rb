FactoryBot.define do
  factory :ipo_profile do
    symbol { 'DANR'}
    exchange { 'NASDAQ' }
    shares { 32.0 }
    price_low { 22.0 }
    price_high { 25.0 }
    estimated_volume { 752.0 }
    managers { 'Bank of America Merril Lynch/ J.P. Morgan/ Morgan Stanley' }
    co_managers { 'Blackstone Capital Markets/ CIBC World Markets' }
    expected_to_trade { Date.today }
    status { 'Priced' }
    offer_date { Date.today + 7.days }
    first_day_close_price { 25.0 }

    company
    industry
  end
end
