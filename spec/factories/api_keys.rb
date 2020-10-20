FactoryBot.define do
  factory :api_key do
    access_token { SecureRandom.hex }
    secret_key { SecureRandom.hex }
    active { true }
  end
end
