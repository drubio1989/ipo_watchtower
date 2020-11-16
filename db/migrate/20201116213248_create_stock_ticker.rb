class CreateStockTicker < ActiveRecord::Migration[6.0]
  def change
    create_table :stock_tickers do |t|
      t.string :ticker
      t.timestamps
    end

    add_reference :companies, :stock_ticker, foreign_key: true
  end
end
