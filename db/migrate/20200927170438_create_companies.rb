class CreateCompanies < ActiveRecord::Migration[6.0]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :description
      t.string :industry
      t.integer :employees
      t.date :founded
      t.string :address
      t.string :phone_number
      t.string :web_address
      t.string :view_prospectus
      t.float :market_cap
      t.float :revenue
      t.float :net_income

      t.timestamps
    end
  end
end
