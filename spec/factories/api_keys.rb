FactoryBot.define do
  factory :api_key do
    access_token { SecureRandom.hex }
    secret_key { SecureRandom.hex }
    active { true }

    trait :disabled do
       after :create do |key|
         key.disable
       end
     end
  end
end
