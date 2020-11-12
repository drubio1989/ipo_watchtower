class AddSlugToIpoProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column :ipo_profiles, :slug, :string
    add_index :ipo_profiles, :slug, unique: true
  end
end
