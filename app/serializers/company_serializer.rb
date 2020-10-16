class CompanySerializer
  include JSONAPI::Serializer

  set_type :company

  link :self do |object|
    "localhost:3000/api/v1/ipo/companies/#{object.slug}"
  end

  attributes :name, :description, :industry, :employees,
    :founded, :address, :phone_number,
    :web_address, :view_prospectus, :market_cap,
    :revenue, :net_income

  has_one :ipo_profile
end
