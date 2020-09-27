FactoryBot.define do
  factory :company do
    name { Faker::Company.name }
    description { 'A leading provider in some kind of industry. We build cool products' }
    industry { Faker::Company.industry }
    employees { 100 }
    founded { Date.today }
    address { Faker::Address.full_address }
    phone_number { Faker::PhoneNumber.phone_number }
    web_address { 'www.company.com' }
    view_prospectus { 'www.company.com/prospectus.com' }
    market_cap { 4806.5}
    revenue { 2378.2 }
    net_income { 38.3 }
  end
end
