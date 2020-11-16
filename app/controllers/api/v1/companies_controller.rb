module Api::V1
  class CompaniesController < ApplicationController

    def index
      options = {}
      options[:fields] = company_fields
      @companies = Company.name_starts_with_letter(filter_params)
      serialize(@companies, options)
    end

    def show
      options = {}
      options[:include] = [:ipo_profile]
      options[:fields] = ipo_profile_fields
      ticker = StockTicker.find_by(ticker: params[:symbol])
      raise ActiveRecord::RecordNotFound.new "No company found for ticker #{params[:symbol]}" if ticker.nil?
      @company = ticker.company
      serialize(@company, options)
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
      filter = params.fetch(:filter, { name: 'A' })
      filter[:name]
    end

    def serialize(object, options = {})
      render json: CompanySerializer.new(object, options).serializable_hash.to_json, status: :ok
    end
  end
end
