FactoryBot.define do
  factory :company do
    random = Random.new
    name { Faker::Company.name }
    description { Faker::Company.bs  }
    industry { Faker::Company.industry }
    employees { random.rand(200) }
    founded { Date.today - random.rand(365).days }
    address { Faker::Address.full_address }
    phone_number { Faker::PhoneNumber.phone_number }
    web_address { 'www.company.com' }
    view_prospectus { 'www.company.com/prospectus.com' }
    market_cap { 4806.5}
    revenue { 2378.2 }
    net_income { 38.3 }
  end
end
