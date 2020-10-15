FactoryBot.define do
  factory :industry do
    name { Faker::IndustrySegments.industry }
  end
end
