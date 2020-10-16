module Api::V1
  class IpoProfilesController < ApplicationController
    include JSONAPI::Pagination

    before_action :fetch_ipos

    def last_100
      jsonapi_paginate(@ipos.limit(100)) do |ipos|
        serialize(ipos, listing_fields)
      end
    end

    def last_12_months
      jsonapi_paginate(@ipos.order(created_at: :desc)) do |ipos|
        serialize(ipos, listing_fields)
      end
    end

    def current_year_pricings
      jsonapi_paginate(@ipos.where(created_at: Date.new(2020,1,1)..Date.today).order(created_at: :desc)) do |ipos|
        serialize(ipos, listing_fields)
      end
    end

    def ipo_calendar
      jsonapi_paginate(@ipos.where(file_date: Date.new(2020,10,1)..Date.new(2020, 10, 31))) do |ipos|
        serialize(ipos, calendar_info_fields)
      end
    end

    def recently_filed
      jsonapi_paginate(@ipos.where(file_date: Date.today - 30.days..Date.today).order(created_at: :desc)) do |ipos|
        serialize(ipos, recently_filed_fields)
      end
    end

    private

    def calendar_info_fields
      { ipo: [:company, :symbol, :managers, :shares, :price_low, :price_high, :estimated_volume, :expected_to_trade] }
    end

    def listing_fields
      { ipo: [:company, :symbol, :industry, :offer_date, :shares, :offer_price, :first_day_close_price, :current_price, :rate_of_return] }
    end

    def recently_filed_fields
      { ipo: [:file_date, :company, :symbol, :managers, :shares, :price_low, :price_high, :estimated_volume, :expected_to_trade] }
    end

    def fetch_ipos
      @ipos = IpoProfile.includes(:company, :industry)
    end

    def serialize(objects, sparse_fields = {})
      render jsonapi: objects, fields: sparse_fields
    end
  end
end
