class IpoProfileSerializer
  include JSONAPI::Serializer

  set_type :ipo

  attributes :company do |object|
    object.company.name
  end

  attributes :industry do |object|
    object.industry.name
  end

  attributes :symbol, :shares, :offer_date, :shares
  attributes :offer_price do |object|
    object.price_low
  end

  attributes :first_day_close_price, :current_price, :return,
  :exchange, :estimated_volume, :managers, :co_managers,
  :status, :expected_to_trade

  attributes :price_range do |object|
    "#{object.price_low}" + "-" + "#{object.price_high}"
  end
end
