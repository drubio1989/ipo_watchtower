class CompanySerializer
  include JSONAPI::Serializer

  set_type :company

  link :self do |object|
    "#{ENV["DOMAIN_URL"]}/api/v1/companies/#{object.stock_ticker.ticker}"
  end

  attributes :name, :description, :industry, :employees,
    :founded, :address, :phone_number,
    :web_address, :market_cap,
    :revenue, :net_income

  has_one :ipo_profile
end
