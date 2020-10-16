module Api::V1
  class CompaniesController < ApplicationController

    def show
      options = {}
      options[:include] = [:ipo_profile]
      options[:fields] = ipo_profile_fields
      @company = Company.find(params[:id])
      serialize(@company, options)
    end

    private

    def ipo_profile_fields
      { ipo: [:company, :symbol, :industry, :shares, :exchange, :estimated_volume, :managers, :co_managers, :status, :expected_to_trade, :price_range] }
    end

    def serialize(object, options)
      render json: CompanySerializer.new(object, options).serializable_hash.to_json, status: :ok
    end
  end
end
