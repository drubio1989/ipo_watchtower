class IpoProfileSerializer
  include JSONAPI::Serializer

  set_type :ipo

  attributes :company do |object|
    object.company.name
  end

  attributes :industry do |object|
    object.industry
  end

  attributes :symbol, :shares, :offer_date, :shares
  attributes :offer_price do |object|
    object.price_low
  end

  attributes :file_date, :first_day_close_price, :price_low, :price_high, :current_price, :rate_of_return,
  :exchange, :estimated_volume, :managers, :co_managers,
  :status, :expected_to_trade

  attributes :price_range do |object|
    "#{object.price_low}" + "-" + "#{object.price_high}"
  end

  belongs_to :company, links: {
    related: -> (object) {
      "#{ENV["DOMAIN_URL"]}/api/v1/ipo/companies/#{object.company.slug}"
    }
  }

end
