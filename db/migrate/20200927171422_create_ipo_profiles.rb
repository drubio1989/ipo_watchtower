class CreateIpoProfiles < ActiveRecord::Migration[6.0]
  def change
    create_table :ipo_profiles do |t|
      t.string :symbol
      t.string :exchange
      t.float :shares
      t.float :price_low
      t.float :price_high
      t.float :estimated_volume
      t.string :managers
      t.string :co_managers
      t.date :expected_to_trade
      t.string :status
      t.timestamps
    end
  end
end
