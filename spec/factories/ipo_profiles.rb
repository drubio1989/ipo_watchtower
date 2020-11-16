FactoryBot.define do
  factory :ipo_profile do
    random = Random.new
    
    exchange { %w[NYSE NASDAQ AMEX].sample }
    shares { random.rand(50).to_f }
    price_low { random.rand(20).to_f }
    price_high { random.rand(50).to_f }
    estimated_volume { random.rand(500).to_f }
    managers { 'Bank of America Merril Lynch/ J.P. Morgan/ Morgan Stanley' }
    co_managers { 'Blackstone Capital Markets/ CIBC World Markets' }
    expected_to_trade { (Date.today.beginning_of_week..Date.today + 2.weeks).to_a.sample }
    industry { %w[HealthCare Financial Technology].sample }
    status { 'Priced' }
    exchange { 'NASDAQ'}
    file_date { (Date.today - 14.days) }
    offer_date { (Date.today + 7.days) }
    first_day_close_price { (20..60).to_a.sample.to_f }
    current_price { (20..60).to_a.sample.to_f }
    rate_of_return { ((current_price - first_day_close_price) / first_day_close_price).ceil(2) }

    company

    trait :within_12_months do
      offer_date { (Date.today.last_year..Date.today).to_a.sample }
    end

    trait :starting_from_beginning_of_year do
      offer_date { (Date.today.beginning_of_year..Date.today).to_a.sample }
    end
  end
end
