class AddIndustryToIpoProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column :ipo_profiles, :industry, :string
    add_column :ipo_profiles, :offer_price, :float
  end
end
