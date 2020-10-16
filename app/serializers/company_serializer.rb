class CompanySerializer
  include JSONAPI::Serializer

  set_type :company

  attributes :name, :description, :industry, :employees,
    :founded, :address, :phone_number,
    :web_address, :view_prospectus, :market_cap,
    :revenue, :net_income

    has_one :ipo_profile
end
