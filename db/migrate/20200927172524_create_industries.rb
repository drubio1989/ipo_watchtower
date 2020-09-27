class CreateIndustries < ActiveRecord::Migration[6.0]
  def change
    create_table :industries do |t|
      t.string :name

      t.timestamps
    end
    add_reference :ipo_profiles, :industry, foreign_key: true, index: true
  end
end
