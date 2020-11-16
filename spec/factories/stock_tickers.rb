FactoryBot.define do
  factory :stock_ticker do
    ticker { ('A'..'Z').to_a.sample(4).join }
  end
end
