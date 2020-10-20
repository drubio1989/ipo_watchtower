class CreateApiKeys < ActiveRecord::Migration[6.0]
  def change
    create_table :api_keys do |t|
      t.string :access_token, index: true, unique: true
      t.string :secret_key, index: true, unique: true
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
