class IpoProfileSerializer
  include JSONAPI::Serializer

  set_type :ipo

  attributes :ticker do |object|
    object.company.stock_ticker.ticker
  end

  attributes :company do |object|
    object.company.name
  end

  attributes :industry do |object|
    object.industry
  end

  attributes :shares, :offer_date
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
      "#{ENV["DOMAIN_URL"]}/api/v1/companies/#{object.company.stock_ticker.ticker}"
    }
  }

end
