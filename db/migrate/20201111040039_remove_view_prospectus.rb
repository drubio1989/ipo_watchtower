class RemoveViewProspectus < ActiveRecord::Migration[6.0]
  def change
    remove_column :companies, :view_prospectus
  end
end
