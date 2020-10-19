module Api::V1
  class CompaniesController < ApplicationController
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    
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
      @company = Company.friendly.find(params[:id])
      serialize(@company, options)
    end

    private

    def not_found(exception)
      render json: {
        errors: [
          "status"=> "404",
          "title"=>"Record Not Found",
          "detail"=> exception.message
        ]
      },
      status: :not_found
    end

    def company_fields
      { company: [:name] }
    end

    def ipo_profile_fields
      {
        ipo: [:company, :symbol, :industry, :shares, :exchange,
        :estimated_volume, :managers, :co_managers, :status,
        :expected_to_trade, :price_range]
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
