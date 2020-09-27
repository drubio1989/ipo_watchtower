class AddRefToIpoProfiles < ActiveRecord::Migration[6.0]
  def change
    add_reference :ipo_profiles, :company, foreign_key: true, index: true
  end
end
