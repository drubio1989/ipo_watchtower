class AddMoreFieldsToIpoProfile < ActiveRecord::Migration[6.0]
  def change
    add_column :ipo_profiles, :first_day_close_price, :float
    add_column :ipo_profiles, :offer_date, :date
    add_column :ipo_profiles, :current_price, :float
    add_column :ipo_profiles, :rate_of_return, :float
    add_column :ipo_profiles, :file_date, :date
  end
end
