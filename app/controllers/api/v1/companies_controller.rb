module Api::V1
  class CompaniesController < ApplicationController
    def show
      options = {}
      options[:include] = [:ipo_profile]
      @company = Company.find(params[:id])
      serialize(@company, options)
    end

    private

    def serialize(object, options)
      render json: CompanySerializer.new(object, options).serializable_hash.to_json, status: :ok
    end
  end
end
