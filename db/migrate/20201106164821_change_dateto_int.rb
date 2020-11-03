class ChangeDatetoInt < ActiveRecord::Migration[6.0]
  def change
    remove_column :companies, :founded
    add_column :companies, :founded, :integer
  end
end
