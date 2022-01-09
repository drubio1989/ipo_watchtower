module Api::V1
  class CompaniesController < ApplicationController

    def index
      options = {}
      options[:fields] = company_fields
      @companies = Company.name_starts_with_letter(filter_params)
      serialize(@companies, options)
      fresh_when @companies
    end

    def show
      options = {}
      options[:include] = [:ipo_profile]
      options[:fields] = ipo_profile_fields
      ticker = StockTicker.find_by(ticker: params[:ticker])
      raise ActiveRecord::RecordNotFound.new "No company found for ticker #{params[:ticker]}" if ticker.nil?
      @company = ticker.company
      serialize(@company, options)
      fresh_when @company
    end

    private

    def company_fields
      { company: [:name] }
    end

    def ipo_profile_fields
      {
        ipo: [:ticker, :industry, :exchange, :shares, :price_range, :estimated_volume, :managers, :co_managers, :expected_to_trade, :status]
      }
    end

    def filter_params
      filter = params.fetch(:filter, 'A' )
    end

    def serialize(object, options = {})
      render json: CompanySerializer.new(object, options).serializable_hash.to_json, status: :ok
    end
  end
end
