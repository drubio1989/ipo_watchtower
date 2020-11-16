module Api::V1
  class IpoProfilesController < ApplicationController
    include JSONAPI::Pagination

    before_action :fetch_ipos
    before_action :fetch_stock_ticker, only: [:show]

    def last_100
      jsonapi_paginate(@ipos.where("DATE(offer_date) >= ?", Date.today.last_year).limit(100)) do |ipos|
        serialize(ipos, listing_fields)
      end
    end

    def last_12_months
      jsonapi_paginate(@ipos.where("DATE(offer_date) >= ?", Date.today.last_year).order(offer_date: :desc)) do |ipos|
        serialize(ipos, listing_fields)
      end
    end

    def current_year_pricings
      jsonapi_paginate(@ipos.where("DATE(offer_date) >= ?", Date.today.beginning_of_year).order(offer_date: :desc)) do |ipos|
        serialize(ipos, listing_fields)
      end
    end

    def ipo_calendar
      jsonapi_paginate(@ipos.where("DATE(expected_to_trade) >= ?", Date.today.beginning_of_week).order(expected_to_trade: :desc)) do |ipos|
        serialize(ipos, calendar_info_fields)
      end
    end

    def recently_filed
      jsonapi_paginate(@ipos.where("DATE(file_date) >= ?", Date.today - 6.months).order(file_date: :desc)) do |ipos|
        serialize(ipos, recently_filed_fields)
      end
    end

    def show
      serialize(@ipo)
    end

    private

    def calendar_info_fields
      {
        ipo: [:company, :symbol, :managers, :shares,
        :price_low, :price_high, :estimated_volume, :expected_to_trade]
      }
    end

    def listing_fields
      {
        ipo: [:company, :symbol, :industry, :offer_date,
        :shares, :offer_price, :first_day_close_price,
        :current_price, :rate_of_return]
      }
    end

    def recently_filed_fields
      {
        ipo: [:file_date, :company, :symbol,
        :managers, :shares, :price_low, :price_high,
        :estimated_volume, :expected_to_trade]
      }
    end

    def fetch_stock_ticker
      ticker = StockTicker.find(symbol: params[:symbol])
      @ipo = ticker.ipo_profile
    end

    def fetch_ipos
      @ipos = IpoProfile.includes(:company)
    end

    def serialize(objects, sparse_fields = {})
      render jsonapi: objects, fields: sparse_fields
    end
  end
end
