module Api::V1
  class IpoProfilesController < ApplicationController
    
    def last_100
      @ipos = IpoProfile.limit(100)
      serialize(@ipos)
    end

    def last_12_months
      @ipos = IpoProfile.order(created_at: :desc)
      serialize(@ipos)
    end

    def current_year_pricings
      @ipos = IpoProfile.where(created_at: Date.new(2020,1,1)..Date.today).order(created_at: :desc)
      serialize(@ipos)
    end

    def ipo_calendar
      @ipos = IpoProfile.where(file_date: Date.new(2020,10,1)..Date.new(2020, 10, 31))
      serialize(@ipos)
    end

    def recently_filed
      @ipos = IpoProfile.where(file_date: Date.today - 30.days..Date.today).order(created_at: :desc)
      serialize(@ipos)
    end

    private

    def serialize(object, sparse_fields = {})
      render json: IpoProfileSerializer.new(object, sparse_fields).serializable_hash.to_json, status: :ok
    end
  end
end
